# SaveAPenny Mobile

Production Flutter client for the [SaveAPenny](https://github.com/battletech45/saveapenny-backend)
personal-finance API. Client only — business rules (simulation, validation,
feasibility) live on the backend; this app calls the API and presents results.

## Prerequisites

- Flutter SDK `3.47.0` or newer on the stable channel. The app requires Dart
  `^3.12.2` from `pubspec.yaml`; the verified local toolchain is Flutter
  `3.47.0` with Dart `3.13.0`.
- A running SaveAPenny backend for local development (see the backend README:
  `docker compose up --build`).
- iOS: recent Xcode with the iOS Simulator installed, CocoaPods, and a valid
  Apple development setup for device builds.
- Android: Android Studio, Android SDK/platform tools, and a recent emulator or
  physical device.
- Firebase configuration files for real device/push builds (`GoogleService-Info.plist`
  for iOS and `google-services.json` for Android), provided outside git.
- RevenueCat SDK keys supplied with `--dart-define-from-file` (see below).

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # once code/annotations exist
```

## Running

The base URL is injected at build time via `--dart-define-from-file` (never hardcoded).
Android and iOS take separate keys — `API_BASE_ANDROID_URL` /
`API_BASE_IOS_URL` — because the emulator and simulator resolve `localhost`
differently (the Android emulator is its own network namespace; the host is
reachable at `10.0.2.2`, not `localhost`).

```bash
# Local backend — both platforms in one run
flutter run \
  --dart-define=API_BASE_ANDROID_URL=http://10.0.2.2:8080 \
  --dart-define=API_BASE_IOS_URL=http://localhost:8080 \
  --dart-define=APP_FLAVOR=dev

# Staging / Prod (same URL works for both platforms)
flutter run \
  --dart-define=API_BASE_ANDROID_URL=https://api.saveapenny.app \
  --dart-define=API_BASE_IOS_URL=https://api.saveapenny.app \
  --dart-define=APP_FLAVOR=prod
```

Tip: keep these in VS Code `launch.json` configs or a `Makefile` so you don't
retype them.

### RevenueCat SDK keys

The RevenueCat keys (`REVENUECAT_IOS_SDK_KEY`, `REVENUECAT_ANDROID_SDK_KEY`) are
also compile-time `--dart-define` values — **not** read from a `.env` file
(`String.fromEnvironment` only resolves values passed at build time). Instead of
typing every `--dart-define` by hand, use a JSON file with `--dart-define-from-file`:

```bash
cp dart_define/dev.example.json dart_define/dev.json   # once, then fill in real keys
flutter run --dart-define-from-file=dart_define/dev.json
```

`dart_define/*.json` is gitignored except the `*.example.json` templates — never
commit real RevenueCat keys.

## Common commands

```bash
dart run build_runner watch --delete-conflicting-outputs   # during active dev
flutter analyze                                            # must pass clean
flutter test                                               # unit + widget + golden
flutter gen-l10n                                           # regenerate localizations
dart format .
```

## Project structure

```
.
├── CLAUDE.md / AGENTS.md      # AI operating rules (read first)
├── analysis_options.yaml      # strict lints (enforced)
├── build.yaml                 # codegen config (freezed/json/riverpod)
├── l10n.yaml                  # localization config
├── docs/
│   ├── ARCHITECTURE.md        # structure, layering, conventions
│   ├── API_CONTRACT.md        # backend envelope, auth, errors, pagination
│   ├── DESIGN_SYSTEM.md       # color/type/spacing tokens, components
│   ├── ROADMAP.md             # feature status and remaining work
│   └── adr/                   # architecture decision records
└── lib/
    ├── core/                  # network, error, config, theme, storage, router, l10n
    ├── features/<feature>/    # data / domain / application / presentation
    ├── app.dart               # MaterialApp.router, theme, l10n wiring
    └── main.dart              # ProviderScope + bootstrap
```

## Documentation

| Doc | Read it when |
|-----|--------------|
| [CLAUDE.md](CLAUDE.md) | Before writing or generating any code |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Deciding where code goes |
| [docs/API_CONTRACT.md](docs/API_CONTRACT.md) | Building any API call or DTO |
| [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Building any UI |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Picking what to build next |
| [docs/adr/](docs/adr/) | Understanding why a locked-in pattern exists before "helpfully" reversing it |

## Developing with AI

This repo is set up for AI-assisted development. `CLAUDE.md` (symlinked/copied to
`AGENTS.md`) is the operating contract — point the agent at it, and ask it to
follow the pattern in the relevant `features/` slice. The strict
`analysis_options.yaml` is the safety net: if generated code drifts, it fails
analysis.

## Localization

Bilingual Turkish + English. Strings live in `lib/l10n/app_en.arb` (template) and
`lib/l10n/app_tr.arb`; `flutter gen-l10n` generates `AppLocalizations`. No
hardcoded user-facing strings — see `CLAUDE.md` §9. `generate: true` is set under
`flutter:` in `pubspec.yaml`.

## Generated code

`*.g.dart` and `*.freezed.dart` are **gitignored** (see `.gitignore`) — run
`build_runner` locally and in CI rather than committing generated output.

## License

Private — not published (`publish_to: 'none'`).
