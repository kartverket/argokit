#!/usr/bin/env bash
set -euo pipefail

SHA=$(git rev-parse HEAD)
BASE_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "dev")

# Determine tag state
if ! git diff --quiet || ! git diff --cached --quiet; then
    # Working tree or index is dirty
    TAG="${BASE_TAG}-dirty"
elif [ "$(git rev-list "${BASE_TAG}..HEAD" --count)" -gt 0 ]; then
    # Clean tree but ahead of the last tag
    TAG="${BASE_TAG}-next"
else
    # Clean, exactly at the tag
    TAG="${BASE_TAG}"
fi

cat > version.libsonnet <<EOF
{
  sha: '${SHA}',
  tag: '${TAG}',
}
EOF
