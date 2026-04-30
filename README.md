# zylos-contracts

The single source of truth for cross-service contracts in the Zylos platform.

This repository holds:

- **Protobuf** definitions for gRPC service-to-service communication.
- **Apache Avro** schemas for Kafka event publishing.

Every Zylos backend service depends on this repository. Schema changes are
gated by automated compatibility checks (`buf breaking` for Protobuf;
Schema Registry compatibility for Avro at registration time).

## Repository Structure

- proto/zylos/`<domain>`/v`<N>`/   -  Protobuf contracts (gRPC)
- avro/zylos/`<domain>`/v`<N>`/    - Avro schemas (Kafka events)
- docs/                        - Schema rules, ADRs, envelope spec
- scripts/                     - Lint, breaking-change check, codegen
- .github/workflows/           - CI: lint + breaking-change gates

## Prerequisites

- [Buf CLI](https://buf.build/docs/installation) v1.32.0+
- `jq` (for Avro validation): `sudo apt install jq`
- Java 25 (only required if regenerating Java code locally)

## Common Tasks

| Task | Command |
|------|---------|
| Lint Protobuf | `./scripts/lint.sh` |
| Detect breaking changes | `./scripts/breaking.sh` |
| Generate Java from Protobuf | `./scripts/generate-java.sh` |
| Validate Avro JSON | `./scripts/validate-avro.sh` |

## Adding a New Contract

See [`docs/adding-a-new-contract.md`](docs/adding-a-new-contract.md).

## Schema Evolution Rules

See [`docs/schema-evolution.md`](docs/schema-evolution.md). **Read this before
changing any contract.**

## Architecture Decisions

- [ADR 0001: Buf over `protoc`](docs/adr/0001-buf-over-protoc.md)
- [ADR 0002: Avro for Kafka events](docs/adr/0002-avro-for-kafka-events.md)
- [ADR 0003: Versioned package strategy](docs/adr/0003-versioned-package-strategy.md)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
