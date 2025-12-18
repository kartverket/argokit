#!/usr/bin/env bash
set -euo pipefail

SHA=$(git rev-parse HEAD)

# Try to get last tag
if BASE_TAG=$(git describe --tags --abbrev=0 2>/dev/null); then
    COMMITS_SINCE_TAG=$(git rev-list "${BASE_TAG}..HEAD" --count)
    echo "Found base tag: ${BASE_TAG} with ${COMMITS_SINCE_TAG} commits since"
else
    BASE_TAG="dev"
    COMMITS_SINCE_TAG=$(git rev-list HEAD --count)
    echo "Found base tag: ${BASE_TAG} with ${COMMITS_SINCE_TAG} commits since"
fi

# Determine tag state
if ! git diff --quiet || ! git diff --cached --quiet; then
    TAG="${BASE_TAG}-dirty"
    echo "Working tree is dirty"
elif [ "$COMMITS_SINCE_TAG" -gt 0 ]; then
    TAG="${BASE_TAG}-$COMMITS_SINCE_TAG"
    echo "There are $COMMITS_SINCE_TAG commits since the last tag"
else
    TAG="${BASE_TAG}"
    echo "At exact tag ${BASE_TAG}"
fi

cat > version.libsonnet <<EOF
{
  sha: '${SHA}',
  tag: '${TAG}',
}
EOF

echo "Generated version.libsonnet with sha ${SHA} and tag ${TAG}"

