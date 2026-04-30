# Check for breaking changes against the main branch.
# Run locally before opening a PR; same command runs in CI.

set -euo pipefail

cd "$(dirname "$0")/.."

# Use the GitHub remote ref. Falls back to local main if remote unavailable.
TARGET="${BUF_BREAKING_TARGET:-.git#branch=main}"

echo "==> Running buf breaking against ${TARGET}..."
buf breaking --against "${TARGET}"

echo "✓ No breaking changes detected."
