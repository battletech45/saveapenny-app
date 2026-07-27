# Roadmap — SaveAPenny Mobile

Current state of the client, organized by backend feature family. Use this to
see what's implemented, what's still hardening, and what to pick up next.
Follow the layered pattern in `ARCHITECTURE.md`, the operating rules in
`CLAUDE.md`, the backend contract in `API_CONTRACT.md`, and the visual rules in
`DESIGN_SYSTEM.md`. A slice is not done until it meets the Definition of Done
at the bottom.

Backend feature flags to respect (these return `503` when off and must be
handled gracefully): `ASSISTANT_DISABLED`, `STOCK_DISABLED`,
`INSIGHTS_DISABLED`, `GOAL_PROGRESS_DISABLED`.

---

## Implemented feature families

| Family | Notes |
|---|---|
| Foundation & app shell | `core/` (config, network, error, storage, router, theme, formatting), `l10n/` (TR/EN), `main.dart`/`app.dart` |
| Auth & session | register/login/refresh/logout, secure token storage, proactive + reactive refresh, auth-aware router redirects |
| Accounts | list/create/update/delete |
| Categories | system vs. user categories, create/update/delete |
| Transactions | paginated list, income/expense/transfer flows, account-sync after mutation |
| Budgets | CRUD, status-oriented modeling and UI |
| Recurring transactions | CRUD, frequency/lifecycle handling, history view |
| Reports | monthly summary, category spending, cash flow, net worth snapshots |
| Notifications | list, unread count, mark read/mark-all-read, delete |
| Users / profile | `users/me`, profile update, password change (incl. reused-password handling) |
| Goals | CRUD, scenarios, simulation, what-if, progress checks |
| Stocks | holdings CRUD + summary, quotes, daily series, news, overview, financial statements, technical indicators (SMA/EMA/RSI), rate-limit- and disabled-state-aware UX |
| Imports | CSV preview/confirm/status polling, per-row error reporting |
| Assistant | AI chat UI, local conversation persistence, disabled-state handling |
| Insights | automated observations list + detail, disabled-state handling |
| OCR | receipt upload, async job polling, candidate confirmation flow |
| Dashboard | home surface aggregating net worth, monthly income/expense, at-risk budgets, and upcoming bills from existing repositories |
| Onboarding | first-run flow after registration (accounts/categories setup) |
| Navigation shell | `StatefulShellRoute` with a persistent bottom `NavigationBar` (Home / Transactions / Plan / Portfolio / More), each branch keeping its own stack |
| Billing | entitlement + purchase flow via RevenueCat (`purchases_flutter`), paywall gating on premium features |
| Push | device token registration with the backend; `firebase_messaging` wired |
| Crash reporting & analytics | `firebase_crashlytics`, `firebase_analytics` dependencies wired |

All of the above have unit/widget tests for their happy path, and an
`integration_test/auth_flow_test.dart` E2E entrypoint exists.

---

## Not planned

Nothing from the backend's feature surface is currently out of scope. If a new
backend family ships, pull its DTO shape from `/v3/api-docs` and build the
slice using an existing feature as the reference pattern.

---

## Ongoing hardening (Phase G)

Even where a slice already exists end-to-end, this work stays open-ended:

- Verify every implemented DTO against `/v3/api-docs` as the backend evolves.
- Keep `Failure` mapping exhaustive as backend error codes expand.
- Expand widget/golden coverage for key screens.
- Expand end-to-end coverage beyond auth into core money flows.
- Verify feature-disabled (`503`) behavior for every flagged backend family.
- Verify dark mode and 1.3x text scaling on all key screens.
- Confirm no raw user-facing strings slip into new UI.
- Run `dart run build_runner build --delete-conflicting-outputs` before
  committing after deleting/renaming an `@riverpod`-annotated source file, so
  no orphaned `*.g.dart` build artifacts linger locally.

## Store readiness

Non-code items still needed before a store submission:

- [ ] Privacy policy & data disclosure — map what's actually collected
  (email, transaction data, secure tokens) to Apple's App Privacy labels and
  Play's Data Safety form.
- [ ] Store screenshots captured against the current dashboard and nav shell.
- [ ] Verify `flutter_launcher_icons` / `flutter_native_splash` output against
  final brand assets (config already active in `pubspec.yaml`).

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

## Suggested cadence for new work

1. Pick one item from "Ongoing hardening" or "Store readiness" above.
2. Pull field-level DTO details from `/v3/api-docs` if the work touches a
   contract.
3. Keep repository errors throwing typed `Failure`s only.
4. Add/update TR/EN strings before considering the UI complete.
5. Run codegen, analyze, and tests before moving on.
