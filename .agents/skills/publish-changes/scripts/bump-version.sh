#!/bin/bash
set -euo pipefail

BUMP="${1:-patch}"
VERSION_FILE="${2:-VERSION}"

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Version file not found: $VERSION_FILE" >&2
  exit 1
fi

current=$(cat "$VERSION_FILE")
if [[ ! "$current" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version format: $current" >&2
  exit 1
fi

IFS=. read -r major minor patch <<< "$current"

case "$BUMP" in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  patch)
    patch=$((patch + 1))
    ;;
  *)
    echo "Usage: $0 [patch|minor|major] [version-file]" >&2
    exit 1
    ;;
esac

new_version="$major.$minor.$patch"
echo "$new_version" > "$VERSION_FILE"
echo "$new_version"
