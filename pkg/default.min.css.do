PATH="$(npm bin):${PATH}"

redo-ifchange "${2}.css"
uglifycss "${2}.css" 