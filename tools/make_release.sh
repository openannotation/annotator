#!/bin/bash

TAG="${1}"

if [[ -z "${TAG}" ]]; then
  echo "Usage: $(basename "${0}") X.Y.Z"
  exit 1
fi

git diff-index --quiet --cached HEAD \
  && git diff-files --quiet \
  && git ls-files --others --exclude-standard

if [[ "${?}" != "0" ]]; then
  echo "Not creating release in dirty environment"
  exit 1
fi

set -x
cake package
cake package:kitchensink
git co master
git add -f pkg/*

tree=$(git write-tree)
parent=$(git rev-parse master)

commit=$(echo "Annotator release ${TAG}" | git commit-tree "${tree}" -p "${parent}")

git tag "${TAG}" "${commit}"
git reset HEAD pkg/
rm -Rf pkg/*
