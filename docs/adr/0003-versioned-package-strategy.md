# ADR 0003: Versioned Package Strategy

- **Status:** Accepted
- **Date:** 2026-04-30
- **Deciders:** Kamesh Chathuranga

## Context

When a contract must change in a backward-incompatible way, how do we manage
the transition without breaking consumers?

## Decision

**Each version of a contract is a separate, immutable, top-level package** —
both in the directory path and in the Protobuf `package` declaration:

- Path: `proto/zylos/catalog/v1/product.proto`
- Package: `zylos.catalog.v1`

A breaking change creates `proto/zylos/catalog/v2/...` alongside `v1`. Both
coexist. Consumers migrate at their own pace. `v1` is removed only after every
consumer has migrated.

For Avro events, the equivalent is a new topic version:
`order.events.v1` → `order.events.v2`. Producers can dual-publish during
migration windows.

## Rationale

- **Independent evolution**: Consumers and producers don't have to deploy
  simultaneously.
- **Rollback safety**: An aborted migration doesn't strand consumers on a
  partially-migrated schema.
- **Audit clarity**: It's obvious from the path what version a service uses.
- **CI enforceable**: `buf breaking` blocks accidental in-place breaking
  changes within a version.

## Trade-offs Accepted

- More directories.
- Slight code duplication during migration windows.

## Alternative Rejected: In-Place Mutation with "BREAKING:" Commits

Tempting and lighter-weight, but it stops working the moment more than one
service consumes the contract. Not viable at Zylos scale.