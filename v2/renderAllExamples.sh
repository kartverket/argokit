#!/usr/bin/env bash
set -u

failed=()
ok=0
total=0

while IFS= read -r -d '' f; do
    total=$((total + 1))
    if jsonnet "$f" > /dev/null; then
        ok=$((ok + 1))
    else
        failed+=("$f")
    fi
done < <(find examples -type f -name '*.jsonnet' -print0)

printf '\nSummary:\n'
printf '  Total: %s\n' "$total"
printf '  Succeeded: %s\n' "$ok"
printf '  Failed: %s\n' "${#failed[@]}"

if (( ${#failed[@]} )); then
    printf '\nFailed files:\n'
    for f in "${failed[@]}"; do
        printf '  %s\n' "$f"
    done
    exit 1
fi
