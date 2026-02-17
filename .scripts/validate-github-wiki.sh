#!/usr/bin/env bash
# Check if a GitHub wiki repository exists.
#
# Usage: .scripts/validate-github-wiki.sh <owner/repo>
#
# Exit codes:
#   0 — wiki exists
#   1 — wiki not found

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: validate-github-wiki.sh <owner/repo>" >&2
  exit 1
fi

SLUG="$1"

# Always use HTTPS for validation regardless of user's clone URL protocol
if ! git ls-remote "https://github.com/$SLUG.wiki.git" HEAD >/dev/null 2>&1; then
  echo "error: wiki for '$SLUG' not found. The wiki may not have been initialized yet." >&2
  exit 1
fi
