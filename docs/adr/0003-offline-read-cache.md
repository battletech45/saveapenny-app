# 0003 — Encrypted read-only cache, no offline mutations

- **Status:** Accepted
- **Date:** 2026-08-19
- **Deciders:** Altay

## Context

The client has no offline handling today: every screen depends on a live API
call, and a dropped connection (subway, flaky signal) surfaces as a blank
`Failure.network` error even when the same data was successfully fetched
seconds earlier. `AccountsController.sync()` already reverts to the last
in-memory `AsyncData` on a failed refresh, but that only covers a *warm* app —
cold start offline or a relaunch after being killed has nothing to fall back
to, since nothing is persisted to disk.

Any persistence of API responses also creates a new risk: account balances
and transaction history would sit on disk, which changes the app's data
protection surface beyond what `flutter_secure_storage` (tokens only, per
CLAUDE.md §2 rule 5) currently covers.

## Decision

We will add a **read-only, encrypted, event-driven cache** at the repository
layer:

- Repositories write-through the last successful GET/create/update/delete
  response (as DTO JSON) to a `ResponseCacheStore`, and fall back to it only
  when a call fails with `Failure.network` and there is no in-memory state.
- Every cached blob is encrypted with AES-GCM before touching disk. The
  256-bit key lives in `flutter_secure_storage` under its own namespace
  (`cache_encryption_key`), separate from auth tokens — secure storage holds
  only the key, never the bulk data, since Keychain/Keystore are size-capped
  and slow for large blobs.
- The cache has **no TTL and no background/periodic refresh**. It only
  updates when a normal foreground call (cold start, pull-to-refresh, a
  mutation) succeeds online. Staleness is surfaced to the user via a
  `lastSyncedAt()` timestamp ("Updated 3h ago") rather than hidden behind
  silent auto-refresh or a guessed expiry.
- **Mutations are not queued offline.** If the device is offline,
  create/update/delete are blocked client-side with a clear message. No
  conflict resolution or sync engine is in scope.
- Cache scope is read-heavy, slow-changing data: dashboard, accounts,
  transactions (most recent page only), budgets, categories, recurring
  transactions, reports. Explicitly **not** cached: stocks (a cached quote is
  wrong, not just stale), assistant/OCR/imports (job-based, not meaningful
  offline), notifications (high churn, low value).
- Cache files and the encryption key are both wiped on logout, in the same
  step as the auth token purge.

## Alternatives considered

- **Plaintext JSON file cache** — simplest, but leaves account balances and
  transaction history readable by anything with filesystem access (jailbreak/
  root, backup extraction). Rejected: this is a finance app; the data is as
  sensitive as the tokens CLAUDE.md already protects.
- **Hive / Isar / Drift as the cache store** — the data is just "last-good API
  response bodies" keyed by endpoint, not a queryable relational store. A
  full embedded database is more machinery than the problem needs.
- **Storing cached data directly in `flutter_secure_storage`** — Keychain/
  Keystore are designed for small secrets, not bulk paginated data; rejected
  for size/performance reasons, not a security concern.
- **Offline write queue (mutations sync later)** — would require idempotency
  keys, conflict resolution, and background sync triggers for money data.
  Materially larger effort than read caching for a fraction of the value;
  deferred, not ruled out, if product later requires it.
- **Background/periodic refresh (e.g. resume-triggered refresh-if-stale)** —
  considered as a way to keep the cache warmer automatically. Rejected for v1
  in favor of the plain event-driven model: it adds another moving part
  (lifecycle listeners, per-feature thresholds) for a problem the staleness
  timestamp already solves honestly. Revisit only if users report the shown
  timestamp is misleadingly stale in practice.

## Consequences

- Positive: cold start and app-restart offline now show the last-known data
  instead of a blank error screen; the data at rest is protected to the same
  standard as tokens; no new class of sync bugs (conflict resolution, replay,
  idempotency) is introduced.
- Trade-off: cached data can be arbitrarily old with no forced expiry — the
  UI must always show `lastSyncedAt()` next to cached data, never render it
  indistinguishably from a live response.
- Trade-off: users cannot create/edit/delete anything while offline. This is
  an intentional v1 limitation, not an oversight.
- Follow-ups: a repository must call `ResponseCacheStore.clearAll()` and
  rotate/delete `cache_encryption_key` from the logout flow — treat this as
  part of the logout contract, the same way token clearing is.
- Guard for AI agents: **do not** add a background timer/periodic sync, and
  **do not** add offline mutation queuing, without a new ADR. Both were
  explicitly considered and rejected/deferred here.
