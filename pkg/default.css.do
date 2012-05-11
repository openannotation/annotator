SRC="../css/$(basename "$2").css"
redo-ifchange "$SRC"
../tools/data_uri_ify <"$SRC"