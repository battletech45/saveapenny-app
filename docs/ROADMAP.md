# Roadmap — SaveAPenny Mobile

Build order for the client, derived from the backend's feature set. This file now
reflects the **actual repository state** instead of the original greenfield plan.
Use it to understand what is already implemented, what still needs hardening, and
what feature families remain unbuilt.

Follow the layered pattern in `ARCHITECTURE.md`, the operating rules in
`CLAUDE.md`, the backend contract in `API_CONTRACT.md`, and the visual rules in
`DESIGN_SYSTEM.md`. A slice is not done until it meets the Definition of Done at
the bottom.

Backend feature flags to respect (these return `503` when off and must be handled
gracefully): `ASSISTANT_DISABLED`, `STOCK_DISABLED`, `INSIGHTS_DISABLED`, and
`GOAL_PROGRESS_DISABLED`.

---

## Current repository snapshot

The repository is **well past the foundation stage**. The current `lib/` already
contains:

- `main.dart` + `app.dart`
- `core/` foundation for config, network, errors, router, storage, theme, UI, and
  money formatting
- `l10n/` ARB localization for English and Turkish
- implemented feature slices for:
  - `auth`
  - `accounts`
  - `categories`
  - `budgets`
  - `transactions`
  - `recurring_transactions`
  - `reports`
  - `notifications`
  - `users` (profile + password change)
  - `goals` (CRUD, scenarios, simulation, what-if, progress)
  - `stocks` (holdings, quotes, financials, technical indicators)
- unit/widget tests across those features and `integration_test/auth_flow_test.dart`

This means the old "Phase 0: build lib/ from zero" plan is obsolete. The roadmap
below is organized around the **current maturity** of the repo.

---

## Phase A — Foundation and app shell

**Status:** Implemented in repository

Implemented now:

- `core/config/app_environment.dart`
- `core/network/api_envelope.dart`
- `core/network/api_error_code.dart`
- `core/network/dio_client.dart`
- `core/network/auth_interceptor.dart`
- `core/error/failure.dart`
- `core/storage/secure_token_store.dart`
- `core/router/app_router.dart`
- `core/theme/tokens.dart`
- `core/theme/app_theme.dart`
- `core/ui/loading_view.dart`
- `core/ui/empty_view.dart`
- `core/ui/failure_view.dart`
- `core/formatting/money_formatter.dart`
- `lib/l10n/app_en.arb` and `lib/l10n/app_tr.arb`
- `main.dart` and `app.dart`

Expected ongoing work in this phase:

- keep envelope parsing and `Failure` mapping consistent for every new API call
- keep theme/token usage strict as new UI is added
- expand shared UI states only when a real reuse case appears
- keep localization keys synchronized between `en` and `tr`

---

## Phase B — Auth and session management

**Status:** Implemented in repository

Implemented now:

- endpoints and DTO flow for register, login, refresh, logout
- secure token persistence
- auth-aware router redirects
- proactive and reactive refresh handling in the interceptor
- login and register presentation screens
- auth repository/controller tests plus integration coverage entrypoint

Remaining hardening work as needed:

- verify edge cases against the live backend contract when backend auth behavior changes
- keep forced sign-out/session expiry UX polished and localized

---

## Phase C — Core money features

**Status:** Implemented in repository

Implemented now:

1. `accounts`
   - list/create/update/delete flows
   - typed domain/DTO/repository/application/presentation layers
2. `categories`
   - system vs user category handling
   - create/update/delete flows
3. `transactions`
   - paginated list
   - income, expense, and transfer flows
   - account-sync behavior after transaction mutations

Expected ongoing work in this phase:

- keep DTOs aligned with `/v3/api-docs`
- tighten validation and failure-path UX where backend behavior evolves
- add more test coverage when new transaction/account/category rules are introduced

---

## Phase D — Planning features

**Status:** Implemented in repository

Implemented now:

1. `budgets`
   - CRUD flows
   - status-oriented modeling and UI
2. `recurring_transactions`
   - recurring entry management
   - frequency/lifecycle handling
   - history-oriented presentation and tests

Expected ongoing work in this phase:

- validate lifecycle/status behavior against backend contract changes
- continue covering primary failure-path behavior in tests

---

## Phase E — Reporting and communication

**Status:** Implemented in repository

Implemented now:

1. `reports`
   - monthly summary
   - category spending
   - cash flow points
   - net worth snapshots
2. `notifications`
   - list/read-state-oriented flows
   - presentation and repository/controller tests

Expected ongoing work in this phase:

- expand report interactions only if backend endpoints justify it
- keep empty/error/loading states consistent with shared UI conventions

---

## Phase F1 — Users, goals, and stocks

**Status:** Implemented in repository

Implemented now:

1. **Users / profile**
   - `users/me`
   - profile update flows
   - password change UX (including reused-password error handling)
2. **Goals**
   - CRUD
   - scenarios
   - simulation
   - what-if
   - progress checks
3. **Stocks**
   - holdings CRUD + summary
   - quotes, daily series, news, overview
   - financial statements (income statement, balance sheet, cash flow)
   - technical indicators (SMA, EMA, RSI)
   - rate-limit- and disabled-state-aware UX

Known gap (see Phase G): `stock_detail_controller`, `stock_financials_controller`,
and `stock_indicators_controller` still need unit test coverage — only
`stock_holdings_controller` has a controller test today.

Implementation-quality fixes already applied from the Phase G audit:
- `StockDetailController`/`GoalDetailController` (both `family` providers)
  switched from `keepAlive: true` to `autoDispose` — each was leaking a full
  detail-state tree per symbol/goal ID visited, for the lifetime of the app.
- All `loadMore()` pagination logic (transactions, notifications, goals,
  goal detail runs, budgets, recurring transactions + history, stock holdings)
  now shares `core/riverpod/load_more_guard.dart`'s `LoadMoreGuard` mixin
  instead of 6+ copy-pasted implementations, and swallowed load-more errors
  are now logged via `dart:developer` instead of vanishing silently.
- `auth_interceptor.dart`'s 401 retry path no longer force-logs-out a user
  when token refresh succeeds but the retried request fails for an unrelated
  reason (timeout/5xx/offline).

## Phase F2 — Remaining backend families not yet present

**Status:** Not yet implemented in repository

These backend families are still missing from `lib/features/` and are the main
source of remaining scope:

1. **Assistant**
   - AI chat UI and API integration
   - disabled-state handling when the feature flag is off
2. **Insights**
   - automated observations
   - disabled-state handling
3. **Imports**
   - CSV preview and confirm workflow
4. **OCR**
   - receipt upload
   - async job polling
   - candidate confirmation flow
5. **Audit logs**
   - history screens and pagination

Recommended build order for the remaining families:

1. `imports`
2. `ocr`
3. `insights`
4. `assistant`
5. `audit_logs`

Reasoning:

- `imports` and `ocr` are substantial but bounded vertical slices that extend
  the core transaction-entry flow
- `insights` and `assistant` depend heavily on feature-flag-aware UX and backend
  readiness
- `audit_logs` is useful but less critical than core user-facing finance flows

---

## Phase G — Hardening, parity, and release readiness

**Status:** Ongoing

Even where slices already exist, the repo still needs continuous completion work:

- verify every implemented DTO against `/v3/api-docs`
- keep `Failure` mapping exhaustive as backend error codes expand
- fill any missing happy-path and primary failure-path tests, including known
  gaps identified by audit:
  - `transactions`: add a repository-level test (`transactions_repository_test.dart`)
    covering both success and thrown-`Failure` paths — currently only DTO
    mapping is tested
  - `reports`: `reports_repository_test.dart` only covers happy paths; add a
    failure-path case (thrown `Failure` on a `success:false` envelope or
    `DioException`)
  - `stocks`: add controller tests for `stock_detail_controller`,
    `stock_financials_controller`, and `stock_indicators_controller` (only
    `stock_holdings_controller` has coverage today)
- expand widget/golden coverage for key screens
- expand end-to-end coverage beyond auth into core money flows
- verify feature-disabled (`503`) behavior for flagged backend families
- verify dark mode and 1.3x text scaling on all key screens
- confirm no raw user-facing strings slip into new UI
- run `dart run build_runner build --delete-conflicting-outputs` before
  committing after deleting/renaming an `@riverpod`-annotated source file, so
  no orphaned `*.g.dart` build artifacts linger locally

---

## Definition of Done (per slice)

- [ ] Follows the `features/<name>/` layered layout
- [ ] DTOs are `freezed` and verified against `/v3/api-docs`
- [ ] All calls go through the envelope; errors map to `Failure`
- [ ] Loading / empty / error states implemented; no blank screens
- [ ] UI uses only design tokens; amounts signed + tabular + colored
- [ ] All strings localized in TR + EN
- [ ] Server feature-flag (`503`) handled if applicable
- [ ] Tests cover the happy path and the primary failure path
- [ ] `flutter analyze` clean; codegen regenerated per policy

---

## Suggested cadence for future work

1. Pick one missing backend family from Phase F2.
2. Pull field-level DTO details from `/v3/api-docs`.
3. Build the slice in `features/<name>/` using the existing implemented slices as the reference pattern.
4. Keep repository errors throwing typed `Failure`s only.
5. Add TR/EN strings before considering the UI complete.
6. Run codegen, analyze, and tests before moving to the next slice.
