# Adding a New Contract

This document covers the workflow for adding a new Protobuf service or Avro
event schema. **Read [`schema-evolution.md`](./schema-evolution.md) first.**

## Workflow

1. **Create a feature branch** off `main`: 
   `git checkout -b feature/<id>-add-<contract-name>`

2. **Decide which directory the contract belongs in.**
   - gRPC service contract → `proto/zylos/<domain>/v1/`
   - Kafka event schema → `avro/zylos/<domain>/v1/`

3. **Write the contract.**
   - Protobuf: see existing files for style. Use `STANDARD` Buf lint rules.
   - Avro: include the standard envelope (see [`envelope-spec.md`](./envelope-spec.md)).

4. **Run local checks:**
   - `./scripts/lint.sh`
   - `./scripts/breaking.sh`
   - `./scripts/validate-avro.sh`

5. **Commit using Conventional Commits:**
   `git commit -m "feat(catalog): add Product gRPC service contract"`

6. **Open a PR.** CI runs lint, breaking-change detection, and Avro validation.
   Review and merge after green CI.

## Naming Conventions (Protobuf)

| Element | Convention | Example |
|---------|------------|---------|
| Package | `zylos.<domain>.v<N>` | `zylos.catalog.v1` |
| File name | `lower_snake_case.proto` | `product_service.proto` |
| Message | `PascalCase` | `Product`, `CreateProductRequest` |
| Field | `lower_snake_case` | `product_id`, `display_name` |
| Enum | `PascalCase` | `ProductStatus` |
| Enum value | `UPPER_SNAKE_CASE` with prefix | `PRODUCT_STATUS_ACTIVE` |
| Service | `<Resource>Service` | `ProductService`, `OrderService` |
| RPC | `PascalCase` verb | `GetProduct`, `CreateOrder` |

## Naming Conventions (Avro)

| Element | Convention | Example |
|---------|------------|---------|
| File name | `lower_snake_case.avsc` | `order_placed.avsc` |
| Namespace | `app.zylos.<domain>.v<N>` | `app.zylos.order.v1` |
| Record name | `PascalCase` | `OrderPlaced` |
| Field | `camelCase` (Avro convention; differs from Protobuf intentionally) | `orderId`, `placedAt` |

## Why Different Field Casing for Avro vs Protobuf?

Protobuf and Avro have different community conventions. Following each
language's native style produces idiomatic generated code in both. The
difference is intentional and documented here so no one "fixes" it.
