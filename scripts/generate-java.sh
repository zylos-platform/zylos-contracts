# Regenerate Java code from Protobuf definitions.
# Output goes to gen/java/ (not committed; consumed by services via repackaging).

set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Generating Java code..."
buf generate

echo "✓ Generated code written to gen/java/"
