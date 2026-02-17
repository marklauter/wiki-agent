#!/usr/bin/env bash
# Parse a GitHub clone URL to extract owner and repository name.
#
# Usage: .scripts/parse-clone-url.sh <url>
# Output (eval-able): OWNER='owner' REPO_NAME='repo'
#
# Exit codes:
#   0 — parsed successfully
#   1 — invalid or unrecognized URL

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: parse-clone-url.sh <clone-url>" >&2
  exit 1
fi

URL="$1"

# Match HTTPS (github.com/owner/repo) and SSH (github.com:owner/repo)
if [[ "$URL" =~ github\.com[/:]([^/]+)/([^/.]+)(\.git)?/?$ ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO_NAME="${BASH_REMATCH[2]}"
else
  echo "error: could not parse owner/repo from URL: $URL" >&2
  echo "Accepted formats:" >&2
  echo "  https://github.com/owner/repo.git" >&2
  echo "  https://github.com/owner/repo" >&2
  echo "  git@github.com:owner/repo.git" >&2
  echo "  git@github.com:owner/repo" >&2
  exit 1
fi

echo "OWNER='$OWNER'"
echo "REPO_NAME='$REPO_NAME'"
