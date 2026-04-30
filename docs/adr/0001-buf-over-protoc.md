# ADR 0001: Use Buf Instead of protoc for Protobuf Tooling

- **Status:** Accepted
- **Date:** 2026-04-30
- **Deciders:** Kamesh Chathuranga

## Context

Zylos uses Protobuf for gRPC service contracts. The historical default tool
is `protoc` plus a constellation of language-specific plugins. Buf is a modern
alternative built specifically to address `protoc`'s shortcomings.

## Decision

We use **Buf v2** as the canonical Protobuf toolchain for `zylos-contracts`.

## Rationale

- **Linting**: Buf provides 40+ lint rules enforcing API style consistency.
  `protoc` has no lint capability.
- **Breaking change detection**: `buf breaking` against the prior commit on `main`
  catches incompatible changes before merge. Without this, schema drift is
  detected at runtime in production.
- **Workspace support**: Buf v2 has first-class multi-module workspace support
  (one repo, multiple logical modules). `protoc` requires manual `-I` flag
  juggling.
- **Buf Schema Registry (BSR)**: We don't currently use the hosted BSR (cost,
  account complexity), but we benefit from BSR-compatible config files. We
  retain the option to push later.
- **Industry adoption**: Buf is the modern standard for Protobuf
  tooling at scale.

## Trade-offs Accepted

- One more tool in the developer toolchain.
- Slight learning curve for engineers familiar only with `protoc`.

## Alternatives Considered

- **Plain `protoc`** — rejected: no linting, no breaking-change detection.
- **Bazel + rules_proto** — rejected: massive over-engineering for Zylos's scale.