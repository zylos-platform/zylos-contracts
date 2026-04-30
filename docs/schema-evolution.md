# Schema Evolution Rules

> **Read this before changing any contract.** Every rule here exists because
> a real production system, somewhere, broke when this rule was violated.

## Core Principle

A schema in `zylos-contracts` is a **published contract**. Once a version is on
`main`, the only changes allowed are *additive and backward-compatible*. Any
breaking change requires a **new version** (`v2`, `v3`, etc.).

This applies whether the contract is consumed by 1 service or 100. Treat
`main` as if every change ships to production immediately — because it does.

---

## Protobuf (gRPC service contracts)

### Versioning

- Each domain has versioned packages: `zylos.catalog.v1`, `zylos.catalog.v2`, etc.
- The version segment is in the **package name** AND the **directory path**.
- A new major version (e.g., `v1` → `v2`) lives in a new directory; the old version stays in place until all consumers migrate.

### Compatibility Level

We enforce **`WIRE_JSON`** in `buf.yaml`. This means both binary wire format
*and* JSON encoding must remain compatible.

### Allowed Within a Version

- ✅ Add new fields with new tag numbers.
- ✅ Add new RPC methods to an existing service.
- ✅ Add new services.
- ✅ Add new messages.
- ✅ Add new enum values (with care — see "Enum Hazards" below).
- ✅ Mark fields/methods/services as `deprecated = true`.

### Forbidden Within a Version

- ❌ Renaming any field, method, or service.
- ❌ Changing field tag numbers.
- ❌ Removing fields (use `reserved` to retire a tag/name).
- ❌ Changing field types (except safe widening: `int32` → `int64`, `sfixed32` → `sfixed64`, etc.).
- ❌ Changing field cardinality (singular ↔ repeated, optional ↔ required).
- ❌ Reusing a previously-used tag number for a different field.

### Enum Hazards

Adding enum values is technically wire-compatible, but consumers parsing an
unknown value behave language-dependent. **Always include `<ENUM>_UNSPECIFIED = 0`**
and treat unknown values defensively in code.

### Deprecation Process

1. Add new field/method alongside the old one.
2. Mark the old one with `[deprecated = true]`.
3. Update all consumers to use the new field.
4. Wait at least one full release cycle.
5. Remove the old field via a `reserved` declaration in a new major version (`v2`).

---

## Avro (Kafka event schemas)

### Compatibility Level

We use **`BACKWARD`** compatibility (Confluent Schema Registry default).

- A consumer using **schema version N** can read messages produced with **schema version N or N-1**.
- This is what lets us deploy producer changes without coordinating with consumers.

### Allowed Within a Version (Backward-Compatible Changes)

- ✅ Add a new field **with a default value**.
- ✅ Remove a field **that has a default value**.
- ✅ Document changes (`doc` field).
- ✅ Add new symbols to an enum (last position only; with default).

### Forbidden Within a Version

- ❌ Renaming a field (except via `aliases`, which is a rare advanced technique).
- ❌ Adding a new field without a default.
- ❌ Removing a field that has no default.
- ❌ Changing a field's type incompatibly.
- ❌ Changing a field from optional to required (or vice versa).

### Breaking Changes → New Topic Version

Breaking schema changes require a new topic: `order.events.v2`. Producers can
dual-publish during migration; consumers migrate at their own pace.

---

## The Event Envelope

Every Avro event in Zylos shares a common envelope. See [`envelope-spec.md`](./envelope-spec.md).

---

## Review and Approval

Schema changes are reviewed by the *consuming* service's owner — see `CODEOWNERS`.
A producer cannot unilaterally change a contract that consumers depend on.

---

## CI Enforcement

Every PR to `main` runs:

- `buf lint` — style and best practices.
- `buf breaking` — against `main` to catch incompatible changes.
- Avro schema validation — JSON well-formedness; manual review for compatibility.

A red CI run blocks the PR. There is no override.