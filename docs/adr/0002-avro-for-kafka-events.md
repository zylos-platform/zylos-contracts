# ADR 0002: Use Avro for Kafka Event Schemas

- **Status:** Accepted
- **Date:** 2026-04-30
- **Deciders:** Kamesh Chathuranga

## Context

Zylos publishes domain events to Kafka. We need a serialization format that:

1. Is binary-efficient at high throughput.
2. Enforces schemas at the broker boundary (via Schema Registry).
3. Supports schema evolution with explicit compatibility rules.
4. Has mature Java tooling.

## Decision

Use **Apache Avro** with **Confluent Schema Registry** for all Kafka events.

## Rationale

- **Wire size**: Avro binary is ~50–70% smaller than JSON for the same data.
  At Zylos's scale, this directly reduces Kafka storage and network costs.
- **Schema evolution**: Avro's compatibility rules (BACKWARD, FORWARD, FULL)
  are well-defined and enforceable at registry-write time. Producers and
  consumers evolve independently.
- **Schema Registry integration**: Confluent Schema Registry stores schemas
  centrally; Avro messages embed only a 4-byte schema ID. Consumers fetch
  schemas on demand.
- **Kafka ecosystem fit**: Confluent's `KafkaAvroSerializer` and
  `KafkaAvroDeserializer` are first-party, well-maintained, and integrate
  cleanly with Spring Kafka.
- **Java tooling**: The `avro-maven-plugin` generates type-safe Java records
  from `.avsc` files at build time.

## Why Not Protobuf for Kafka?

- We use Protobuf for **synchronous gRPC** (request/response).
- We use Avro for **asynchronous Kafka events**.
- Both are valid; we chose Avro for Kafka because Confluent Schema Registry's
  Avro support is the most mature, and Avro's schema-evolution semantics are
  more refined for streaming use cases.
- Single-format dogma is an anti-pattern; using the right tool for each
  channel is correct.

## Why Not JSON?

- No schema enforcement.
- 2–3x larger payloads.
- Schema drift becomes a runtime production issue.

## Trade-offs Accepted

- Two schema formats to maintain (Protobuf + Avro).
- Slightly higher cognitive overhead for new contributors.