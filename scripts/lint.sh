# Lint all Protobuf files in this repository using Buf.
# Run locally before pushing; same command runs in CI.

set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Running buf lint..."
buf lint

echo "==> Running buf format check (no changes will be applied)..."
buf format --diff --exit-code

echo "✓ Lint passed."
