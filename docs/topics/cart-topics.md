# Cart Kafka Topics

Both topics are produced **atomically** from the Cart service's transactional
outbox (a single DynamoDB `TransactWriteItems` → sharded polling relay → Kafka).
See `zylos-service-cart` ADR-0001. Both carry the same Avro schema,
`app.zylos.contracts.cart.v1.CartEvent` (TopicNameStrategy → one subject per topic).

| Topic                   | cleanup.policy | Retention | Key      | Purpose                                                                                                                                                                                      |
|-------------------------|----------------|-----------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cart.cart.events.v1`   | `delete`       | 30d       | `cartId` | Ordered funnel/event log. Consumed by Analytics, Recommendation, and abandoned-cart detection. `eventType` carries intent; `payload` carries full state.                                     |
| `cart.cart.snapshot.v1` | `compact`      | —         | `cartId` | Compacted latest-state per cart. Fast bootstrap for materialized views and the DynamoDB↔topic relay-completeness reconciliation. Tombstoned (null value) on `CartConverted` / `CartExpired`. |

## Keying & ordering

Partition key = `cartId` (raw string, not Avro-encoded), guaranteeing per-cart
ordering. Relay shard affinity is on `cartId`, preserving that ordering end-to-end.

## eventType values

`CartLineAdded`, `CartLineQuantityChanged`, `CartLineRemoved`, `CartCleared`,
`CartMerged`, `CartConverted`, `CartExpired`. There is **no** `CartCreated`: carts
are created lazily, so the first event on a cart's stream is a `CartLineAdded`.

## Tombstones

On `cart.cart.snapshot.v1` only, terminal events (`CartConverted`, `CartExpired`)
are published as a **null Kafka record value** keyed by `cartId`, so log
compaction reclaims the cart. The `cart.cart.events.v1` log is delete-retained
and needs no tombstone; terminal events remain in it as normal records until they
age out.

## Schema Registry subjects

- `cart.cart.events.v1-value` → `CartEvent`
- `cart.cart.snapshot.v1-value` → `CartEvent`
- Keys are raw strings (`cartId`); no `-key` Avro subject.

Compatibility: **BACKWARD** (per `docs/schema-evolution.md`). The two `KafkaTopic`
Strimzi manifests themselves live in `zylos-infra-gitops`.
