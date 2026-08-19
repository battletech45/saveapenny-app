# CLAUDE.md — SaveAPenny Mobile

> This file is the source of truth for how code is written in this repo.
> Read it fully before generating or editing code. If a request conflicts
> with these rules, follow the rules and flag the conflict.
> (Symlink `AGENTS.md → CLAUDE.md` so other AI tools pick up the same rules.)

## 1. What this is

The production Flutter client for **SaveAPenny**, a personal-finance API.
The backend is a Spring Boot 4.1 / Java 24 service (PostgreSQL). This repo is
**client only** — it never owns business rules that already live on the server
(simulation math, feasibility, validation). The app calls the API and presents
results.

- Backend contract: `docs/API_CONTRACT.md` (envelope, auth, errors, pagination)
- Architecture & conventions: `docs/ARCHITECTURE.md`
- OpenAPI source of truth: `GET {baseUrl}/v3/api-docs` (use this to derive DTOs)

## 2. Golden rules (non-negotiable)

1. **Never hand-write generated files.** Models, providers, and unions are
   produced by `build_runner`. Edit the source annotation, then regenerate.
2. **Every API response is wrapped in the envelope** (`success/data/error/timestamp`).
   Always parse through `ApiEnvelope<T>` — never read `data` directly off raw JSON.
3. **Map errors to the typed `Failure` hierarchy.** UI/state code reacts to
   `Failure`, never to raw `DioException` or HTTP status integers.
4. **Error codes come from the backend.** Use the `ApiErrorCode` enum in
   `lib/core/network/api_error_code.dart`. Do not invent codes; if the server
   adds one, add it to the enum from `docs/error-codes` — don't string-match.
5. **Tokens live only in `flutter_secure_storage`.** Never in SharedPreferences,
   Hive, plaintext, or app state that gets logged.
6. **Feature-first structure.** New functionality goes in `lib/features/<name>/`
   following the layered pattern, not scattered across shared folders.
7. **No business logic in widgets.** Widgets read providers and render. Logic
   lives in notifiers/services.
8. **Bilingual from day one.** No hardcoded user-facing strings — all copy goes
   through `intl` ARB localization (Turkish + English). See §9.

## 3. Stack & the role of each package

| Concern | Package | Rule |
|---|---|---|
| State | `flutter_riverpod` + `riverpod_generator` | Codegen only: `@riverpod` + `Notifier`/`AsyncNotifier`. No legacy `StateProvider`/`ChangeNotifier`. |
| Models | `freezed` + `json_serializable` | All DTOs and domain models are `freezed` classes with `fromJson`. |
| HTTP | `dio` | One configured `Dio` instance via the client in `core/network`. Never `new Dio()` ad hoc. |
| Routing | `go_router` | One router config. Route guards via the auth state. No `Navigator.push` for top-level navigation. |
| Secure storage | `flutter_secure_storage` | Tokens and nothing-else-sensitive. |
| Offline cache | `connectivity_plus`, `cryptography` | Read-only, encrypted, event-driven cache (`core/storage/response_cache_store.dart`) for GET responses. See §7 and `docs/adr/0003-offline-read-cache.md`. |
| Formatting | `intl` | All dates, currency, numbers. Backend dates are ISO-8601; currencies ISO-4217. |
| i18n | `flutter_localizations` + ARB | TR/EN. |

## 4. Architecture (summary — full version in docs/ARCHITECTURE.md)

```
lib/
  core/            # cross-cutting: network, error, config, storage, router, theme, l10n
  features/
    <feature>/
      data/        # *_api.dart (Dio calls), *_repository.dart, DTOs
      domain/      # entities (freezed), repository interfaces (if abstracted)
      application/ # @riverpod notifiers/providers, state classes
      presentation/# screens/, widgets/
  app.dart         # MaterialApp.router, theme, localization wiring
  main.dart        # ProviderScope + bootstrap
```

Data flow is one-directional:
`presentation → application (provider) → repository → api → Dio → backend`

**Failure convention (LOCKED): repositories throw mapped `Failure`s.** They never
return `Result`/`Either`. Notifiers wrap calls in `AsyncValue.guard` so the thrown
`Failure` lands in `AsyncValue.error`, and the UI renders it via `.when(error: ...)`.
See §7 for the canonical snippet.

## 5. State management conventions

- Declare providers with `@riverpod` (codegen). File ends in nothing special;
  the generated part is `*.g.dart`.
- Async data uses `AsyncNotifier` / `FutureProvider`; expose `AsyncValue<T>` to
  the UI and handle `loading/error/data` explicitly — no silent empty states.
- Side-effecting actions (login, create transaction) are methods on a `Notifier`
  that return a `Future` and update state; the widget awaits and reacts.
- Keep provider scope tight; prefer `ref.watch` for reads, `ref.read` only in
  callbacks.

## 6. Models & serialization

- One `freezed` class per DTO. JSON keys are **already camelCase** on the backend
  (`accessToken`, `totalItems`) — do **not** apply `field_rename`.
- Use `@JsonKey` only for genuine mismatches.
- IDs are UUID strings. Money is `Decimal`-like — parse to `num`/`String`
  carefully; never use `double` arithmetic for money in the client. Display via
  `intl` `NumberFormat.currency`.
- Dates: parse ISO-8601 to `DateTime`; treat date-only fields as such.

## 7. Networking & errors

- All calls go through the shared `Dio` client (base URL from `AppEnvironment`,
  envelope parsing, auth + refresh interceptor).
- Parse with `ApiEnvelope<T>.fromJson(json, T.fromJson)`. On `success:false`,
  convert `error` → `ApiFailure` via `ApiErrorCode`.
- Auth: dual-token. Access JWT (15 min) + opaque refresh (7 d, rotated each use).
  The interceptor refreshes **proactively** when the JWT is within 60 s of expiry,
  and reactively on a 401, retrying once. On refresh failure → clear tokens →
  route to login. (Backend spec: `docs/API_CONTRACT.md` §Auth.)
- Respect `Retry-After` on `429 RATE_LIMITED`.

### Canonical error pattern (copy this)

```dart
// data/<feature>_api.dart — throws on failure, returns parsed data on success.
Future<T> _send<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Object? data) fromData,
    ) async {
  try {
    final res = await call();
    final env = ApiEnvelope<T>.fromJson(res.data as Map<String, dynamic>, fromData);
    if (env.isError) {
      throw FailureMapper.fromApiError(env.error!);
    }
    return env.data as T;
  } on DioException catch (e) {
    throw FailureMapper.fromDio(e);
  }
}

// application/<feature>_controller.dart — let the Failure flow into AsyncValue.
@riverpod
class TransactionsController extends _$TransactionsController {
  @override
  Future<List<Transaction>> build() => ref.read(transactionsRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => ref.read(transactionsRepositoryProvider).list(),
    ); // a thrown Failure becomes AsyncError(Failure)
  }
}

// presentation — render the typed Failure.
ref.watch(transactionsControllerProvider).when(
data: (items) => TransactionList(items),
loading: () => const LoadingView(),
error: (err, _) => FailureView(err as Failure), // localized via err.code
);
```

### Offline read cache (see `docs/adr/0003-offline-read-cache.md`)

Read-heavy repository methods (list/detail GETs, not every call) may fall back to
an encrypted on-device cache when they fail with `Failure.network`, so a cold app
launch with no connection shows the last-known data instead of a blank error.
This is **opt-in per method**, not a blanket rule — only wrap a call if a stale
value is actually useful to show (account balances: yes; a live stock quote: no).

```dart
// data/<feature>_repository.dart
Future<List<Thing>> list() async {
  final items = await cachedFetch<List<ThingResponse>>(
    cache: _cache,
    key: 'things:list',
    call: () async => (await _thingsApi.list()).items,
    toJson: (items) => <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(),
    },
    fromJson: (json) => (json['items']! as List<dynamic>)
        .map((item) => ThingResponse.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );
  return items.map((item) => item.toDomain()).toList(growable: false);
}
```

Rules:
- Cache DTOs (`toJson`/`fromJson`), never domain models — domain classes don't
  carry JSON codecs by design (§6).
- Key by the calendar period the data represents when the call takes a
  date/time param that's effectively always "now" (see `ReportsRepositoryImpl`)
  — an exact-timestamp key would write but never read back.
  For paginated lists, cache only the first, unfiltered page — never a
  filtered/searched view, never `page > 0`.
- After a successful mutation, invalidate the affected key(s)
  (`ResponseCacheStore.invalidate`/`invalidatePrefix`) rather than trying to
  patch the cached value in place.
- On logout, the auth repository purges the whole cache and rotates its
  encryption key — don't add a cache that bypasses that (no writing outside
  `ResponseCacheStore`).
- No TTL, no background refresh. Staleness is surfaced to the user
  (`CacheStalenessLabel` + `lastSyncedAt()`), never hidden behind a silent
  auto-refresh or a guessed expiry.

## 8. Navigation

- Single `GoRouter`. Auth-gated routes redirect to `/login` when unauthenticated,
  driven by the auth provider's state.
- Deep-link-friendly path names; no business logic in route builders.

## 9. Localization

- Languages: `tr`, `en`. ARB files in `lib/l10n/`.
- Every user-facing string uses the generated `AppLocalizations`. PRs that add raw
  strings should fail review.
- Error messages shown to users are mapped from `ApiErrorCode` to localized copy,
  not the raw server `message`.

## 10. Design language

Minimal, restrained, professional — a calm, precise finance aesthetic. The full
spec is `docs/DESIGN_SYSTEM.md`; tokens live in `lib/core/theme/tokens.dart` and
the theme in `lib/core/theme/app_theme.dart`.

Hard rules:
- **Never inline** a color, padding, radius, or font size. Use `AppSpacing.*`,
  `AppRadius.*`, `context.colors`, `context.textTheme.*`, `context.finance.*`.
- The brand `primary` (indigo-blue) is for interaction only. Green/red are
  **exclusively** income/expense — never tint a button with a money color.
- Money is never color-alone: always signed (`+`/`−`), right-aligned, tabular
  figures (`context.textTheme.money`). Color via `context.finance.forAmount(x)`.
- Borders over shadows; cards are flat with a 1px outline. Dark mode is required.

## 11. Testing

- Unit-test notifiers and repositories with `mocktail`.
- Widget/golden tests via `golden_toolkit` for key screens.
- E2E via `patrol` for the critical auth + core flows.
- A feature isn't done without tests for its happy path and its primary failure
  path (mapped `Failure`).

## 12. Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after any annotation change
dart run build_runner watch --delete-conflicting-outputs   # during active dev
flutter analyze                                             # must pass clean
flutter test
dart format .
```

## 13. Definition of done (per change)

- [ ] `flutter analyze` clean (no new warnings)
- [ ] `build_runner` run if annotations changed; no stale `*.g.dart`/`*.freezed.dart`
- [ ] No hardcoded user-facing strings
- [ ] Errors flow through `Failure`, not raw exceptions
- [ ] New feature follows the `features/<name>/` layered layout
- [ ] Tests for happy + primary failure path

## 14. Anti-patterns — do NOT

- ❌ `new Dio()` or raw `http` calls outside `core/network`
- ❌ Reading `response.data['data']` without the envelope
- ❌ Catching `DioException` in widgets
- ❌ Storing tokens anywhere but secure storage
- ❌ `setState` for app/domain state (local ephemeral UI state only)
- ❌ Inventing error-code strings or HTTP-status `if (code == 401)` branching in UI
- ❌ Editing `*.g.dart` / `*.freezed.dart` by hand
- ❌ Putting currency math in `double`