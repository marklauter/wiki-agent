#!/usr/bin/env bash
# Check if a GitHub repository exists and is accessible.
#
# Usage: .scripts/validate-github-repo.sh <owner/repo>
#
# Exit codes:
#   0 — repo exists and is accessible
#   1 — not found or no access

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: validate-github-repo.sh <owner/repo>" >&2
  exit 1
fi

SLUG="$1"

if ! gh repo view "$SLUG" --json name >/dev/null 2>&1; then
  echo "error: repository '$SLUG' not found on GitHub or you do not have access." >&2
  exit 1
fi
