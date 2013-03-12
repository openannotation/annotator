CFG="../../contrib/bookmarklet/config.json"
SRC="../../contrib/bookmarklet/src/bookmarklet.js"

redo-ifchange "$SRC"

if [ -r "$CFG" ]; then
  redo-ifchange "$CFG"
  sed -e "/Leave __config__/d" -e "/^__config__$/{r $CFG" -e 'd;}' <"$SRC"
else
  cat "$SRC"
fi
