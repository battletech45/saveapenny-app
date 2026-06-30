# Roadmap — SaveAPenny Mobile

Build order for the client, derived from the backend's feature set. Each phase
depends on the ones before it. Build **one step at a time**, following the layered
pattern in `ARCHITECTURE.md` and the canonical error/UI/design patterns in
`CLAUDE.md` + `DESIGN_SYSTEM.md`. A slice isn't done until it meets the Definition
of Done at the bottom.

Backend feature flags to respect (these return `503` when off — handle
gracefully, never crash): `ASSISTANT_DISABLED`, `STOCK_DISABLED`, insights, and
goal-progress checks.

> **Current state:** `lib/` contains only `main.dart`. Phase 0 below builds the
> entire foundation from zero. Do it top to bottom — each step compiles on its own.

---

## Phase 0 — Build `lib/` from zero (foundation / app shell)

No user-facing features yet; this is the plumbing every later slice imports. The
order matters: lower layers have no dependencies, so build them first. After each
step, run `flutter analyze` (and `build_runner` once annotations appear) and make
sure it's clean before moving on.

### Target structure at the end of Phase 0

```
lib/
├── main.dart                         # ProviderScope + bootstrap
├── app.dart                          # MaterialApp.router: theme, router, l10n
├── core/
│   ├── config/
│   │   └── app_environment.dart      # flavor + base URL (--dart-define)
│   ├── theme/
│   │   ├── tokens.dart               # COLOR PALETTES + spacing/radius/duration/type primitives
│   │   └── app_theme.dart            # FinanceColors extension + AppTheme.light()/dark() + context getters
│   ├── network/
│   │   ├── api_envelope.dart         # ApiEnvelope<T>, ApiError, PaginatedData<T>
│   │   ├── api_error_code.dart       # ApiErrorCode enum (mirrors backend)
│   │   ├── dio_client.dart           # configured Dio instance + interceptors
│   │   └── auth_interceptor.dart     # proactive + reactive token refresh
│   ├── error/
│   │   └── failure.dart              # sealed Failure + Dio/ApiError mapping
│   ├── storage/
│   │   └── secure_token_store.dart   # flutter_secure_storage wrapper (tokens only)
│   ├── router/
│   │   └── app_router.dart           # GoRouter + auth redirect guard
│   ├── formatting/
│   │   └── money_formatter.dart      # intl currency, signed, tabular
│   └── ui/
│       ├── loading_view.dart         # shared skeleton/spinner
│       ├── empty_view.dart           # shared empty state
│       └── failure_view.dart         # maps Failure -> localized copy
├── l10n/
│   ├── app_en.arb                    # template (keys + English)
│   ├── app_tr.arb                    # Turkish
│   └── generated/                    # gen-l10n output (do not edit)
└── features/                         # added from Phase 1 onward
```

### Step 0.1 — Design tokens (no dependencies, build first)

- `core/theme/tokens.dart` — the raw values. Contains the **color palettes**
  (`BrandPalette`, `NeutralPalette`, `FinancePalette` — light + dark), plus
  `AppSpacing`, `AppRadius`, `AppDuration`, `AppFontWeight`, and
  `kTabularFigures`. Every value from `DESIGN_SYSTEM.md` lives here as a `const`.
  This is the "colors file" + spacing/radius/type primitives in one.

✅ Checkpoint: file analyzes clean; no widget references raw hexes anywhere else.

### Step 0.2 — Theme assembly

- `core/theme/app_theme.dart` — the `FinanceColors` `ThemeExtension`
  (income/expense/warning/info, light + dark), `AppTheme.light()/.dark()` building
  `ThemeData` from the tokens (flat bordered cards, 48px buttons, outlined inputs),
  and the `context.colors / context.textTheme / context.finance` getters +
  `TextTheme.money`/`displayMoney` helpers.

✅ Checkpoint: a throwaway widget can read `context.finance.income` and
`context.textTheme.money` in both brightnesses.

### Step 0.3 — Environment config

- `core/config/app_environment.dart` — `AppFlavor` + `AppEnvironment.current`,
  base URL via `--dart-define`, `apiRoot` = `{baseUrl}/api/v1`, timeouts, logging
  flag.

✅ Checkpoint: `AppEnvironment.current.apiRoot` resolves for dev/staging/prod.

### Step 0.4 — Network contract (envelope + error codes)

- `core/network/api_envelope.dart` — `ApiEnvelope<T>`, `ApiError`,
  `PaginatedData<T>` (hand-written generics, parsing per `API_CONTRACT.md`).
- `core/network/api_error_code.dart` — the full `ApiErrorCode` enum mirroring the
  backend catalogue, with `fromWire` fallback and `isAuthExpiry`.

✅ Checkpoint: a sample JSON envelope parses into typed data and a typed error.

### Step 0.5 — Error model

- `core/error/failure.dart` — sealed `Failure` (network / api / unauthenticated /
  rateLimited / unknown) + `FailureMapper` translating `DioException` and
  `success:false` envelopes. **freezed** — first file that triggers
  `build_runner`.

✅ Checkpoint: `dart run build_runner build` generates `failure.freezed.dart`;
analyze clean.

### Step 0.6 — Secure storage

- `core/storage/secure_token_store.dart` — thin wrapper over
  `flutter_secure_storage` exposing `read/write/clear` for access + refresh
  tokens only. No other data, ever.

✅ Checkpoint: unit-testable read/write/clear (mockable in tests).

### Step 0.7 — Dio client + auth interceptor

- `core/network/dio_client.dart` — single configured `Dio` (base URL from env,
  envelope-aware, attaches the `_send`-style helper from `CLAUDE.md` §7).
- `core/network/auth_interceptor.dart` — proactive refresh when the JWT is within
  60s of expiry, reactive single-retry on 401, clear-and-redirect on refresh
  failure, `Retry-After` handling. Per `API_CONTRACT.md` §Auth.

✅ Checkpoint: an authenticated GET attaches the bearer token; a simulated 401
triggers exactly one refresh.

### Step 0.8 — Localization wiring

- `pubspec.yaml` already has `generate: true` under `flutter:`. ✓
- `lib/l10n/app_en.arb` (template) + `lib/l10n/app_tr.arb`; run `flutter gen-l10n`.
- Seed with the handful of strings the shell needs (app title, common actions,
  generic error copy mapped from `ApiErrorCode`).

✅ Checkpoint: `AppLocalizations` generates; `untranslated.txt` is empty (TR keys
match EN).

### Step 0.9 — Shared UI states

- `core/ui/loading_view.dart`, `empty_view.dart`, `failure_view.dart` — the three
  states every async screen reuses. `FailureView` takes a `Failure` and renders
  localized copy + an optional retry. All design-token styled.
- `core/formatting/money_formatter.dart` — `intl` `NumberFormat.currency` by
  ISO-4217 code, sign prefix, returns value + the `context.finance.forAmount`
  color pairing rule.

✅ Checkpoint: a demo screen shows loading → (empty | error | data) using only
these widgets and tokens.

### Step 0.10 — Router + app bootstrap

- `core/router/app_router.dart` — `GoRouter` with a placeholder `/home` and
  `/login`, redirect guard driven by auth state (stubbed until Phase 1).
- `app.dart` — `MaterialApp.router` wiring `AppTheme.light()/.dark()`,
  `themeMode`, the router, and the localization delegates + `supportedLocales`
  (`en`, `tr`).
- `main.dart` — `WidgetsFlutterBinding.ensureInitialized()` →
  `runApp(ProviderScope(child: App()))`.

✅ **Phase 0 exit criteria:** app launches to a placeholder home; light/dark both
render from tokens; locale switches EN/TR; a manual Dio call round-trips through
the envelope + `Failure` mapping; `flutter analyze` clean and codegen committed
per policy.

---

## Phase 1 — Auth (the gate, and the reference slice)

Everything else is user-scoped, so this comes first and becomes the pattern every
later feature copies.

- Endpoints: `POST /auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout`.
- DTOs: register/login requests, token-pair response (`accessToken`,
  `refreshToken`, `expiresIn`, `tokenType`).
- Flows: register, login, auto-refresh, logout, token-reuse → forced re-login.
- Routing: unauthenticated → `/login`; authenticated → `/home`.
- Screens: login, register (minimal, design-system styled).

**Exit criteria:** full login→token→guarded route→logout cycle; expired refresh
routes to login; `INVALID_PASSWORD` surfaces from strong-password validation.

## Phase 2 — Core money model

1. **Accounts** — list/create/edit; types, currency (ISO-4217), soft delete.
2. **Categories** — system (read-only) vs. user categories.
3. **Transactions & transfers** — income/expense/transfer; the transaction-row
   spec from `DESIGN_SYSTEM.md`; currency-match + balance rules.

**Exit criteria:** add accounts, categorize, record/transfer money; amounts render
signed + colored + tabular; paginated transaction list.

## Phase 3 — Planning

- **Budgets** — monthly/yearly per category; status drives `warning` color.
- **Recurring transactions** — schedule, frequency, lifecycle transitions.

## Phase 4 — Insight & reporting

- **Reports** — monthly summary, net worth snapshots/trend.
- **Notifications** — read/unread tracking, list.

## Phase 5 — Advanced / optional (mostly flagged)

- **Goals** — CRUD, scenarios, simulation, what-if, progress (flag-gated).
- **Stocks** — holdings + quotes; flag-gated, own rate limit.
- **OCR receipt capture** — image upload → async job poll → candidates → confirm.
- **CSV import** — preview → confirm workflow.
- **Insights** — automated observations (flag-gated).
- **Assistant ("Penny Dog")** — AI chat (flag-gated).
- **Audit logs** — change history.

---

## Definition of Done (per slice)

- [ ] Follows the `features/<name>/` layered layout
- [ ] DTOs are freezed + verified against `/v3/api-docs`
- [ ] All calls go through the envelope; errors map to `Failure`
- [ ] Loading / empty / error states implemented (no blank screens)
- [ ] UI uses only design tokens; amounts signed + tabular + colored
- [ ] All strings localized (TR + EN)
- [ ] Server feature-flag (`503`) handled if applicable
- [ ] Tests: happy path + primary failure path
- [ ] `flutter analyze` clean; codegen committed/regenerated per policy

## Suggested cadence for AI-assisted builds

1. Point the agent at `CLAUDE.md` + the target step here.
2. For Phase 0: "Create `<file>` per step `0.x`, following `DESIGN_SYSTEM.md` /
   `API_CONTRACT.md`." One step at a time.
3. From Phase 1: "Build `features/<x>/` following the pattern in `features/auth/`."
4. Generate DTOs from `/v3/api-docs`; review against `API_CONTRACT.md`.
5. Run codegen + analyze; fix until clean. Add the two required tests.
6. Only then move to the next step/slice.