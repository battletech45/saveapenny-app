# Test Suite Audit

> Snapshot date: 2026-07-29, branch `feature/ui-overhaul`, 217 tests passing.
> Purpose: track what's missing so the suite meets the bar in CLAUDE.md §11/§13
> (happy path + primary failure path per feature, golden tests for key screens).
> Check items off as they land; this file is done when every box is checked.

## How to use this file

Each unchecked item is a gap between current coverage and the CLAUDE.md testing
contract. Work top to bottom by priority. When you add a test, check the box and
note the test file path if it differs from the suggested one. Re-run `flutter test`
before checking anything off — a checked box asserts the test exists **and** passes.

The first pass of this audit (data/application/presentation layers per feature)
skipped several `core/` subdirectories and the domain layer. The "P0 — Shared
core utilities" section below was added in a follow-up pass — this file is the
merged result of both, not the original.

---

## P0 — Zero coverage

- [ ] **`push` feature has no tests at all.** `core/push/device_token_registration_service_test.dart`
      covers the service layer, but the underlying Dio call is untested.
  - [ ] `test/features/push/data/device_token_api_test.dart` — happy path (registers
        token, parses envelope) + mapped-`Failure` on error envelope/DioException,
        matching the pattern in every other `*_repository_test.dart`.

---

## P0 — Shared core utilities with zero tests (money, pagination, billing)

These are single-point-of-failure utilities: a bug in any one of them silently
affects every feature that uses it, not just one screen.

- [ ] **`core/formatting/money_formatter.dart`** has no test at all. This is the
      one place that implements the CLAUDE.md §10 hard rule — "Money is never
      color-alone: always signed, ... Color via `context.finance.forAmount(x)`."
      `test/core/formatting/money_formatter_test.dart` should pin: `+` prefix for
      positive, `-` for negative, no sign at exactly zero, `amount.abs()` feeding
      the formatter (not the signed value), and that the returned `color` matches
      `forAmount`.
- [ ] **`core/theme/app_theme.dart` `FinanceColors.forAmount()`** — the
      income/expense/neutral color rule itself has no direct test, only
      incidental exercise via whatever widget happens to render money.
      `test/core/theme/finance_colors_test.dart` — positive → income, negative →
      expense, zero → info.
- [ ] **`core/riverpod/load_more_guard.dart`** — shared pagination mixin used by
      8 controllers (budgets, goals, insights, notifications,
      recurring_transactions, stocks, transactions, goal_detail). No dedicated
      test exists; each controller test may or may not exercise it. Needs its
      own `test/core/riverpod/load_more_guard_test.dart` against a minimal fake
      notifier: no-op while already loading, no-op when `hasNext` is false, no-op
      with no current data, success merges via `merge`, and failure (`Failure`
      and generic `Object`) reverts to the pre-call state without surfacing an
      error.
- [ ] **`core/billing/revenuecat_client.dart`** and
      **`revenuecat_session_sync.dart`** — zero tests. Same risk class as the
      `push` gap below, but higher stakes: this is payment/entitlement sync.
      `test/core/billing/revenuecat_client_test.dart` +
      `revenuecat_session_sync_test.dart` — happy path + failure handling for
      whatever the sync does on a failed RevenueCat call (does it swallow, retry,
      or surface a `Failure`? — confirm intended behavior before writing the test).

---

## P1 — Presentation layer gaps

Widget tests exist for: assistant, billing (paywall/plan-limit), budgets, goals,
imports, ocr, recurring_transactions, stocks, transactions, upgrade. The features
below have presentation code but no dedicated widget test file. Priority order
follows recency of change — `reports` and `users` were just refactored into
dedicated widget files (see recent commits) and are the freshest regression risk.

- [ ] **`reports`** — `test/features/reports/presentation/widgets/reports_cards_test.dart`
      Cover `reports_cards.dart` rendering with populated data and with an
      error/empty state from `reports_shared.dart`.
- [ ] **`users`** — `test/features/users/presentation/widgets/profile_sheets_test.dart`
      Cover `edit_profile_sheet.dart` (submit success + validation/failure copy)
      and `change_password_sheet.dart` (submit success + mismatch/failure copy).
- [ ] **`dashboard`** — `test/features/dashboard/presentation/dashboard_screen_test.dart`
      8 widget files (`net_worth_hero`, `account_row`, `cash_flow_tile`,
      `cash_flow_summary_card`, `attention_strip`, `upcoming_bills_list`,
      `dashboard_section_header`) currently only exercised indirectly through
      `widget_test.dart`'s shell smoke test, which explicitly defers this
      (see its comment). Needs its own suite: populated state, empty state,
      and the `AsyncValue.error` render path.
- [ ] **`accounts`** — `test/features/accounts/presentation/widgets/account_widgets_test.dart`
      `account_card.dart` and `account_form_sheet.dart` — form submit success +
      duplicate/validation failure copy, matching the `budget_widgets_test.dart`
      pattern for this feature family.
- [ ] **`categories`** — `test/features/categories/presentation/widgets/category_widgets_test.dart`
      `category_form_sheet.dart` and `category_tile.dart` — same pattern.
- [ ] **`notifications`** — `test/features/notifications/presentation/notifications_screen_test.dart`
      `notification_tile.dart` rendering (read/unread state) + screen-level
      empty and error states.

---

## P2 — Depth gaps in existing suites

- [ ] **`dashboard_controller_test.dart`** has only 2 test cases for the
      controller that aggregates accounts, cash flow, and upcoming bills —
      thin relative to its complexity. Add cases for: partial-failure
      aggregation (one sub-fetch fails), empty-accounts state, and refresh
      after mutation.
- [ ] Confirm every `application/*_controller_test.dart` has both a success
      case and an `AsyncValue.guard`-wrapped failure case. Spot-checked
      `onboarding_controller_test.dart` (58 lines) and `assistant` for size —
      worth a pass to confirm none silently skip the failure path.

---

## P3 — Missing test category (documented but unused)

- [ ] **`golden_toolkit` is a declared dependency (pubspec.yaml) but has zero
      references anywhere in `test/`.** CLAUDE.md §11 requires golden tests
      for key screens. Either:
      (a) add golden tests for the screens that matter most for visual
      regression — dashboard, accounts, budgets, reports (the ones with the
      richest widget trees) — or
      (b) if golden testing has been deprioritized, remove the dependency and
      update CLAUDE.md §11 so the doc doesn't claim a practice that isn't
      followed.
  - [ ] Decision made and recorded here: _______________

---

## Domain layer — checked, no gap

Audited every `lib/features/*/domain/*.dart` file (excluding generated
`*.freezed.dart`/`*.g.dart` and abstract repository interfaces, which don't
need tests). Sampled across accounts, assistant, auth, billing, budgets,
dashboard, goals, notifications, ocr, and reports:
`budget_status.dart`, `feature_access.dart`, `goal_scenario.dart`,
`goal_run.dart`, `dashboard_snapshot.dart`, `category_spending.dart`,
`ocr_models.dart`, `notification.dart`, `assistant_reply.dart`,
`auth_session.dart`.

Every one is a plain `@freezed` data class: fields, enums, and a `fromJson`
at most — no computed getters, no derivation logic, no branching. Values like
`BudgetHealth`, `GoalFeasibility`, and `OcrJobStatus` are set by the backend
and carried through as-is, consistent with CLAUDE.md §1 ("this repo never owns
business rules that already live on the server"). **No test gap here** — unlike
`money_formatter.dart` / `forAmount()` (P0 above), which do compute
client-side, domain models have nothing to unit test beyond what
`json_serializable`'s own codegen already guarantees.

If a domain file is later found with real logic (a computed getter, a
non-trivial `copyWith` invariant, etc.), it belongs back on this list — this
section is a confirmation for the current snapshot, not a blanket exemption
for the layer going forward.

---

## Out of scope for this audit

- `test/categories_live_test.dart` is intentionally skipped (`Requires running
  local backend`) — not a gap, it's a manual/CI-opt-in smoke test.
- `patrol_test/app_test.dart` and `integration_test/auth_flow_test.dart` cover
  E2E auth; not re-audited here since they're a different test tier (device-level,
  not unit/widget).
- `core/network`, `core/error`, `core/storage` all have direct unit tests and
  were not found to have gaps in this pass.
- `core/config/app_environment.dart`, `core/analytics/analytics_service.dart` —
  checked, low-risk (static config values / telemetry fire-and-forget), not
  worth the test investment relative to everything above.

---

## Completion criteria

This file is fully resolved when:
1. Every checkbox above is checked, with a real test file backing it.
2. `flutter test` passes with no skips other than `categories_live_test.dart`.
3. The P3 golden-testing decision is made one way or the other — not left ambiguous.

At that point this file can be deleted or archived; it's a punch list, not a
permanent doc.
