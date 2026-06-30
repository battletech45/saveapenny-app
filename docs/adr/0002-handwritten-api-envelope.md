# 0002 — Hand-written generic `ApiEnvelope`

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Altay

## Context

Every backend response is wrapped in `ApiResponse<T>` (`success/data/error/
timestamp`), and list endpoints add a generic `PaginatedData<T>`. We parse these
generically across all features. We use freezed + json_serializable for normal
DTOs (their JSON keys are already camelCase, so no renaming).

## Decision

`ApiEnvelope<T>`, `ApiError`, and `PaginatedData<T>` are **hand-written** in
`core/network/api_envelope.dart` with explicit `fromJson(json, fromData)`
factories — not generated. Concrete DTOs that go *inside* the envelope remain
freezed.

## Alternatives considered

- **freezed/json_serializable for the envelope** — generic type parameters plus
  `fromJsonT` converters make the generated code awkward, brittle, and harder to
  read than a small hand-written parser. The friction isn't worth it for ~3
  container types.

## Consequences

- Positive: clear, debuggable parsing for the most-used types; no codegen edge
  cases around generics.
- Trade-off: this file is maintained by hand — but it's small and stable.
- Guard for AI agents: **do not** "convert this to freezed." That reverses this
  decision.