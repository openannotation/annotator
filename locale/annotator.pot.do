../pkg/annotator/annotator-full.deps | while read f; do
  echo "../src/${f}.coffee"
done | xargs xgettext -Lpython -o- -k_t -kgettext --from-code=utf-8