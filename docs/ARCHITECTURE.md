# Architecture & Conventions — SaveAPenny Mobile

This document is the long-form reference behind `CLAUDE.md`. When an AI agent (or
a human) needs to know *where code goes* and *what pattern to follow*, this is the
answer. It deliberately mirrors the backend's feature-sliced structure so the two
codebases feel symmetrical.

## Layering

Feature-first. Each feature is a self-contained vertical slice with four layers:

```
features/<feature>/
  data/
    <feature>_api.dart          # raw Dio calls, returns parsed DTOs or throws mapped Failure
    <feature>_repository.dart   # orchestrates api + caching; the app's entry point to the feature's data
    dto/                        # request/response DTOs (freezed + json)
  domain/
    <feature>.dart              # domain entity (freezed) — what the UI consumes
    <feature>_repository.dart   # (optional) abstract interface if you want to mock at the boundary
  application/
    <feature>_controller.dart   # @riverpod Notifier/AsyncNotifier + state
  presentation/
    <feature>_screen.dart
    widgets/
```

Not every feature needs every layer. Small read-only features can collapse
`domain` into `data`. Keep it proportional — don't ceremony-ify a one-call feature.

## Dependency direction

```
presentation ──► application ──► repository ──► api ──► Dio ──► backend
     ▲                │
     └── watches ─────┘  (AsyncValue<T> / state)
```

- Lower layers never import upper layers.
- `core/` may be imported anywhere; `core/` imports no feature.

## core/ contents

```
core/
  config/    app_environment.dart      # flavors, base URL (--dart-define)
  network/   api_envelope.dart         # ApiEnvelope<T>, ApiError, PaginatedData<T>
             api_error_code.dart       # backend error-code enum (source of truth)
             dio_client.dart           # configured Dio + interceptors        [to build]
             auth_interceptor.dart     # token attach + proactive/reactive refresh [to build]
  error/     failure.dart              # typed Failure hierarchy + Dio mapping
  storage/   secure_token_store.dart   # flutter_secure_storage wrapper        [to build]
  router/    app_router.dart           # GoRouter + auth redirect              [to build]
  theme/     app_theme.dart, tokens.dart  # minimal design tokens              [to build]
  l10n/      (generated AppLocalizations)                                      [to build]
```

`[to build]` = next steps, not yet created.

## The backend contract (authoritative summary)

Full detail in `API_CONTRACT.md`. The essentials every layer assumes:

- **Base:** `{baseUrl}/api/v1`
- **Envelope:** every response is `{ success, data, error, timestamp }`. Parse via
  `ApiEnvelope<T>`.
- **Errors:** `error = { code, message, details[] }`. `code` ∈ `ApiErrorCode`.
- **Auth:** `Authorization: Bearer <accessToken>`. Dual token (JWT 15 min +
  opaque refresh 7 d, rotated each refresh).
- **IDs:** UUID v4 strings. **Dates:** ISO-8601. **Currency:** ISO-4217.
- **Pagination:** `page`/`size`/`sort` request params; response is
  `PaginatedData<T>` (`items`, `page`, `size`, `totalItems`, `totalPages`,
  `hasNext`, `hasPrevious`).

## Conventions

### Naming
- Files: `snake_case.dart`. Classes: `PascalCase`. Providers: `<thing>Provider`
  (generator suffix).
- DTOs end in `Request` / `Response`; domain entities are bare nouns
  (`Transaction`, not `TransactionModel`).

### Result handling (LOCKED — Option A)

**Repositories throw mapped `Failure`s; notifiers catch via `AsyncValue.guard`.**
No `Result`/`Either` type in this codebase.

- `data` layer: on any error, `throw` a `Failure` (mapped from `DioException` or
  a `success:false` envelope). Never return a sentinel/null to signal failure.
- `application` layer: wrap repo calls in `AsyncValue.guard(...)` (or let them
  throw inside an `AsyncNotifier.build`). The `Failure` becomes `AsyncError`.
- `presentation` layer: `ref.watch(provider).when(data:, loading:, error:)`, and
  in `error:` cast to `Failure` and localize by `failure` variant / `ApiErrorCode`.

This keeps control flow idiomatic with Riverpod's `AsyncValue` and avoids
double-wrapping (`AsyncValue<Result<T>>`). The canonical snippet lives in
`CLAUDE.md` §7 — copy it for every new feature.

### Money
Never `double`. Parse to `String`/`num` and format with `intl`
`NumberFormat.currency`. Arithmetic that matters belongs on the server anyway.

### Immutability
All models `freezed` + `const`. No mutable model fields.

## Testing layout

```
test/
  features/<feature>/   # unit: repository + controller (mocktail)
  golden/               # golden_toolkit screen snapshots
integration_test/       # patrol E2E (auth + core flows)
```

## Bootstrap order (main.dart)

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Read `AppEnvironment.current`
3. Build `ProviderScope` (override secure storage / dio for tests)
4. `runApp(App())` → `MaterialApp.router` with router + localization delegates