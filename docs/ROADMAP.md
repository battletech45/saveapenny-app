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

## Phase F — Remaining backend families not yet present

**Status:** Not yet implemented in repository

These backend families are still missing from `lib/features/` and are the main
source of remaining scope:

1. **Users / profile**
   - `users/me`
   - profile update flows
   - password change UX
2. **Goals**
   - CRUD
   - scenarios
   - simulation
   - what-if
   - progress checks
3. **Stocks**
   - holdings
   - quotes
   - rate-limit-aware UX
4. **Assistant**
   - AI chat UI and API integration
   - disabled-state handling when the feature flag is off
5. **Insights**
   - automated observations
   - disabled-state handling
6. **Imports**
   - CSV preview and confirm workflow
7. **OCR**
   - receipt upload
   - async job polling
   - candidate confirmation flow
8. **Audit logs**
   - history screens and pagination

Recommended build order for the remaining families:

1. `users`
2. `goals`
3. `stocks`
4. `imports`
5. `ocr`
6. `insights`
7. `assistant`
8. `audit_logs`

Reasoning:

- `users` is foundational and likely needed for production readiness
- `goals` appears central to the product scope and has multiple dependent backend concepts
- `stocks`, `imports`, and `ocr` are substantial but more bounded vertical slices
- `insights` and `assistant` depend heavily on feature-flag-aware UX and backend readiness
- `audit_logs` is useful but less critical than core user-facing finance flows

---

## Phase G — Hardening, parity, and release readiness

**Status:** Ongoing

Even where slices already exist, the repo still needs continuous completion work:

- verify every implemented DTO against `/v3/api-docs`
- keep `Failure` mapping exhaustive as backend error codes expand
- fill any missing happy-path and primary failure-path tests
- expand widget/golden coverage for key screens
- expand end-to-end coverage beyond auth into core money flows
- verify feature-disabled (`503`) behavior for flagged backend families
- verify dark mode and 1.3x text scaling on all key screens
- confirm no raw user-facing strings slip into new UI

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

1. Pick one missing backend family from Phase F.
2. Pull field-level DTO details from `/v3/api-docs`.
3. Build the slice in `features/<name>/` using the existing implemented slices as the reference pattern.
4. Keep repository errors throwing typed `Failure`s only.
5. Add TR/EN strings before considering the UI complete.
6. Run codegen, analyze, and tests before moving to the next slice.
