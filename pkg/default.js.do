PATH="$(npm bin):${PATH}"

if [ -x "${2}.deps" ]; then
  redo-ifchange "${2}.deps"
  DEPS="$("${2}.deps")"
else
  SRC="$(basename "$2")"
  DEPS="plugin/${SRC#annotator.}"
fi

# implicit dependency on AUTHORS introduced by preamble_cat.sh
redo-ifchange ../AUTHORS

for d in $DEPS; do
  SRC="../src/${d}.coffee"
  redo-ifchange "$SRC"
  echo "$SRC" 
done | xargs ../tools/preamble_cat | coffee -ps