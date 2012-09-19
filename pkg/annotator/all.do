# Build core Annotator
redo-ifchange annotator.min.js
redo-ifchange annotator.min.css
redo-ifchange annotator-full.min.js

# Build plugins
../../tools/plugins | while read p; do
  echo "annotator.${p}.min.js"
done | xargs redo-ifchange