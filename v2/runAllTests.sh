for f in tests/*_test.jsonnet; do
  jsonnet -J vendor "$f" || exit 1
done