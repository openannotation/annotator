CFG="../../contrib/bookmarklet/config.json"
SRC="../../contrib/bookmarklet/src/bookmarklet.js"

redo-ifchange "$SRC" "$CFG"
if [ -r "$CFG" ]; then
  sed "s~__config__~$(cat "$CFG")~" <"$SRC"
else
  cat "$SRC"
fi
