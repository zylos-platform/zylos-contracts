# Zylos Event Envelope Specification

> All Avro events published to Kafka by Zylos services MUST conform to this envelope.

## Rationale

A consistent envelope provides:

- **Tracing**: every event carries `correlationId` and `causationId` for distributed tracing.
- **Routing**: `aggregateId` and `aggregateType` enable consumers to filter and route.
- **Versioning**: `eventType` + `eventVersion` allow non-breaking evolution.
- **Provenance**: `producer` identifies which service emitted the event.
- **Replay safety**: `eventId` (UUID) makes consumer-side idempotency trivial.

## Envelope Fields (Required on Every Event)

| Field | Avro Type | Description |
|-------|-----------|-------------|
| `eventId` | `string` (UUID v7) | Globally unique event identifier. UUIDv7 preferred (time-ordered). |
| `eventType` | `string` | Domain-specific event name, e.g., `OrderPlaced`. |
| `eventVersion` | `int` | Major version of this event's payload schema. |
| `aggregateId` | `string` | ID of the aggregate the event pertains to. |
| `aggregateType` | `string` | E.g., `Order`, `Cart`, `Product`. |
| `occurredAt` | `long` (timestamp-millis) | When the event occurred (in the producer's clock). |
| `correlationId` | `string` (UUID) | Trace ID — same value flows through all events caused by one originating request. |
| `causationId` | `string` (UUID) | The `eventId` of the event that caused this one (or the originating request ID). |
| `producer` | `record` | `{ service: string, version: string }` — which service and version emitted this. |
| `payload` | `record` | The domain-specific fields. Each event type defines its own payload schema. |

## Topic Naming Convention

`<context>.<aggregate>.<event-class>.v<N>`

Examples:
- `catalog.product.events.v1`
- `order.order.events.v1`
- `payment.transaction.events.v1`

## UUIDv7 over UUIDv4

We use **UUIDv7** for `eventId`. UUIDv7 embeds a millisecond timestamp in the
high bits, giving us:

- Time-ordered IDs (better for database indexes, log sorting).
- Same uniqueness guarantees as v4.
- No clock-skew correctness issues at our scale.

Java 25 does not have native UUIDv7; we'll use `com.github.f4b6a3:uuid-creator`
in services. Pinned in the parent POM.

## Worked Example — `OrderPlaced`

The Avro schema (in `avro/zylos/order/v1/order_placed.avsc`) wraps the envelope
around an event-specific payload:

- Envelope fields: as above.
- `payload` for `OrderPlaced`: `{ orderId, customerId, items[], totalAmount, currency, placedAt }`.
