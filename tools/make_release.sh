#!/bin/bash
#
# Dependencies:
#
# jsontool: `npm install -g jsontool`
# s3cmd: `brew install s3cmd && s3cmd --configure`
#

print_usage () {
  echo "Usage: $(basename "${0}") <bump>"
  echo
  echo "  bump - the string 'major', 'minor', or 'patch' denoting the amount by"
  echo "         which to bump the version"
}

confirm_proceed () {
  read -p "${1} [yN]: "
  [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
}

json_key () {
  local json="${1}"
  local key="${2}"
  echo "${response}" | json "${key}" | tr -d '\n'
}

upload_zip () {
  local uname="${1}"
  local passw="${2}"
  local fname="${3}"
  local descr="${4}"

  local response=$(curl -s -u "${uname}:${passw}"  \
    -X POST \
    -H "Accept: application/vnd.github.beta+json" \
    -H "Content-Type: application/json" \
    -d '{
          "name": "'"${fname}"'",
          "size": '"$(stat -f "%z" "${fname}" | tr -d '\n')"',
          "description": "'"${descr}"'",
          "content_type": "application/zip"
        }'\
    https://api.github.com/repos/okfn/annotator/downloads)

  curl \
    -F "key=$(json_key "${response}" path)" \
    -F "acl=$(json_key "${response}" acl)" \
    -F "success_action_status=201" \
    -F "Filename=$(json_key "${response}" name)" \
    -F "AWSAccessKeyId=$(json_key "${response}" accesskeyid)" \
    -F "Policy=$(json_key "${response}" policy)" \
    -F "Signature=$(json_key "${response}" signature)" \
    -F "Content-Type=$(json_key "${response}" mime_type)" \
    -F "file=@${fname}" \
    https://github.s3.amazonaws.com/
}

BUMP="${1}"
OLD_VERSION="$(json version < package.json)"
VERSION_MAJOR="$(echo $OLD_VERSION | cut -d. -f1)"
VERSION_MINOR="$(echo $OLD_VERSION | cut -d. -f2)"
VERSION_PATCH="$(echo $OLD_VERSION | cut -d. -f3)"

case "${BUMP}" in
  major)
    ((VERSION_MAJOR+=1))
    ((VERSION_MINOR=0))
    ((VERSION_PATCH=0))
    ;;
  minor)
    ((VERSION_MINOR+=1))
    ((VERSION_PATCH=0))
    ;;
  patch)
    ((VERSION_PATCH+=1))
    ;;
  *)
    print_usage
    exit 1
    ;;
esac

# Check repo environment

git diff-index --quiet --cached HEAD \
  && git diff-files --quiet \
  && git ls-files --others --exclude-standard

if [[ "${?}" != "0" ]]; then
  echo "Not creating release in dirty environment: ensure that there are no"
  echo "files in the git index and no tracked files with uncommitted changes."
  exit 1
fi

# Confirm new version

VERSION="${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}"
confirm_proceed "Going to release v${VERSION} -- proceed?"

# Update version in package.json

echo "Bumping version in package.json and committing version bump"
perl -pi -e 's/"version":\s*"[^"]*"/"version": "'"${VERSION}"'"/' package.json
git commit package.json -m "Bump version -> v${VERSION}"

# Generate package files

echo "Generating package files"
cake package
cake package:kitchensink

echo "Committing release and creating tag"
git co master
git add -f pkg/*

tree=$(git write-tree)
parent=$(git rev-parse master)

commit=$(echo "Annotator release v${VERSION}" | git commit-tree "${tree}" -p "${parent}")

git tag "v${VERSION}" "${commit}"
git reset HEAD pkg/

# Upload release to S3

echo "Uploading release to S3"
s3cmd --acl-public sync pkg/*.{js,css} "s3://assets.annotateit.org/annotator/v${VERSION}/"

# Make zips and upload to GitHub

echo "Making zips for GitHub"
pushd pkg

mkdir "annotator.${VERSION}"
ln annotator.*.{js,css} "annotator.${VERSION}"
zip -r9 "annotator.${VERSION}.zip" "annotator.${VERSION}"

mkdir "annotator-full.${VERSION}"
ln annotator-full.min.js annotator.min.css "annotator-full.${VERSION}"
zip -r9 "annotator-full.${VERSION}.zip" "annotator-full.${VERSION}"

echo "Uploading zips to GitHub. Please enter your credentials..."
read -p "GitHub username: " uname
stty -echo
read -p "GitHub password: " passw; echo
stty echo

echo "Uploading zips to GitHub"
upload_zip "${uname}" "${passw}" "annotator.${VERSION}.zip" "Annotator ${VERSION} with plugins in individual minified files"
upload_zip "${uname}" "${passw}" "annotator-full.${VERSION}.zip" "Annotator ${VERSION} with plugins all in one minified file"

popd pkg

# Clean up
echo "Cleaning up"
rm -Rf pkg/*
