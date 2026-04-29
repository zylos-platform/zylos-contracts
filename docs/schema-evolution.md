# Schema Evolution Rules — zylos-contracts

## Protobuf (gRPC service contracts)

- **Versioning:** Each domain has versioned packages (`zylos.catalog.v1`, `zylos.catalog.v2`).
- **Compatibility level:** `WIRE_JSON` — both binary and JSON-encoding compatibility maintained.
- **Allowed changes within a version:**
  - Add new fields (with new tags).
  - Add new RPC methods.
  - Add new services.
- **Forbidden changes within a version:**
  - Renaming fields or changing field tags.
  - Removing fields (mark `reserved` instead).
  - Changing field types (except safe widening: int32→int64).
- **Breaking changes** require a NEW version package (`v2`) — never modify in-place.
- All PRs run `buf breaking` against `main` in CI.

## Avro (Kafka event schemas)

- **Compatibility level:** `BACKWARD` (Confluent Schema Registry default).
- Producers can evolve freely; consumers using older schemas continue working.
- **Allowed changes:**
  - Add fields with default values.
  - Remove fields that have default values.
- **Forbidden changes:**
  - Renaming fields.
  - Changing field types incompatibly.
  - Removing fields without defaults.
- Breaking changes require a new event topic version (`order.events.v2`).

## Ownership

Schema changes require approval from the consuming service's owners (see CODEOWNERS).