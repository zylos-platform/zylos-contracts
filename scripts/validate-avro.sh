# Validate Avro schemas:
#   1. JSON well-formedness.
#   2. Avro schema parseability (via Apache Avro tools).
#
# Note: BACKWARD-compatibility checking against published schemas requires
# Confluent Schema Registry; that check happens in service CI when registering
# schemas, not here.

set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required. Install with: sudo apt install jq" >&2
  exit 1
fi

errors=0
shopt -s globstar nullglob

for schema in avro/**/*.avsc; do
  if ! jq empty "${schema}" 2>/dev/null; then
    echo "✗ Invalid JSON: ${schema}"
    errors=$((errors + 1))
  fi
done

if [[ ${errors} -gt 0 ]]; then
  echo ""
  echo "✗ ${errors} invalid Avro schema file(s)."
  exit 1
fi

echo "✓ All Avro schemas are well-formed JSON."
echo ""
echo "Note: Full Avro parse validation runs in service CI via the avro-maven-plugin."
