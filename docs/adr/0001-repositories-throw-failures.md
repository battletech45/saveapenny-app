# 0001 — Repositories throw `Failure` into `AsyncValue`

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Altay

## Context

Every screen needs a consistent way to surface errors (network, validation, auth
expiry, rate limiting). We have a sealed `Failure` type and Riverpod's `AsyncValue` (see `ARCHITECTURE.md` / `CLAUDE.md` §5). We must pick exactly one error-propagation convention so the
data → state → UI path is identical in every feature.

## Decision

Repositories **throw** mapped `Failure`s; they never return a `Result`/`Either`.
Notifiers wrap calls in `AsyncValue.guard` so a thrown `Failure` lands in
`AsyncValue.error`, and the UI renders it via `.when(error: …)`. The canonical
snippet lives in `CLAUDE.md` §7.

## Alternatives considered

- **Return `Result<T>` (sealed Ok/Err)** — explicit and no hidden control flow,
  but double-wraps as `AsyncValue<Result<T>>`, adds boilerplate at every call
  site, and fights Riverpod's built-in error channel.

## Consequences

- Positive: minimal boilerplate; one obvious pattern; errors flow through
  `AsyncValue` idiomatically.
- Trade-off: failure is not visible in a method's return type — discipline (and
  the lint against bare catches) keeps mapping centralized in `FailureMapper`.
- Rule: widgets/notifiers must never see a raw `DioException` or HTTP status int.