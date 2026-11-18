# Quran app

## Toolchain

Use Flutter **3.47.7 stable** (Dart **3.13.5**), pinned in
`.flutter-version` and both GitHub Actions workflows. The dependency lockfile is
committed; use `flutter pub get --enforce-lockfile` for reproducible installs.

Supported native targets:

| Target | Minimum / build requirements |
| --- | --- |
| Android | API 24; SDK/NDK from Flutter; Java/Kotlin bytecode 17; JDK 21 or newer compatible with Gradle 9.8.1; AGP 9.4.0 |
| iOS | iOS 15; current Xcode; CocoaPods for plugins without Swift Package Manager support |
| macOS | macOS 12; current Xcode; CocoaPods |
| Linux | GTK 3, clang, CMake, Ninja, pkg-config, liblzma, libmpv |
| Windows | Visual Studio with Desktop development with C++, Windows SDK, CMake |

Android retains Flutter's compatibility flags for the legacy Gradle DSL and
external Kotlin plugin dependencies. Apple targets use Swift Package Manager
with CocoaPods fallback for the media_kit native audio libraries. Linux and
Windows runner CMake configurations match the current Flutter templates.

Web is not currently supported: there is no web runner, and downloads, font
extraction, and cached audio use native file APIs. Adding a web runner alone
would not make these features browser-compatible.

## Development and validation

```sh
flutter pub get --enforce-lockfile
dart run build_runner build
flutter analyze
flutter test
flutter run
```

The database test checks cached font persistence after reopening SQLite. Schema version 2 adds mushaf-specific word layout keys.
The app still uses experimental just_audio streaming APIs, so analysis reports
those warnings plus an existing getter/setter lint. CI permits warnings and
information diagnostics but fails on analyzer errors.

The validation workflow builds Android, iOS, macOS, Linux, and Windows on their
native hosts. To build locally on the appropriate host:

```sh
flutter build apk --release
flutter build appbundle --release
flutter build ios --release --no-codesign
flutter build macos --release
flutter build linux --release
flutter build windows --release
```

Android release builds currently use the existing debug signing configuration.
Configure your production keystore before store distribution. iOS device
installation and App Store distribution require your signing identity and
provisioning profile; `--no-codesign` only checks compilation.

`flutter pub outdated` can report newer releases of build_runner and transitive
tooling that cannot currently be resolved with the other dependencies. Avoid
forcing these with dependency overrides. Specifically, build_runner 2.17.1
requires build 5, while drift_dev 2.35.1 requires build below 5, so the newest
compatible build_runner is 2.16.2. Direct dependency constraints are tightened to
the latest compatible versions recorded in pubspec.lock.


## Quran Foundation v4 integration

Flutter calls the Cloudflare backend; no client secrets or QF access tokens are
stored in the app. The default is the verified production Worker:

```sh
flutter run
```

Production origin: `https://quran-content-production.mahmoudbahaa-eg.workers.dev`.
Normal runs and CI builds use production. To test prelive explicitly:

```sh
flutter run --dart-define=QURAN_API_BASE_URL=https://quran-content-prelive.mahmoudbahaa-eg.workers.dev
```

Use the same define with `flutter build` when selecting a different backend.
The value must be an HTTPS origin without a path.

The app downloads content on demand, follows verse pagination, refreshes and
caches the chapter-reciter catalog, and loads one chapter's audio metadata at a
time. Fonts and audio assets still download directly from their asset hosts.
Missing word timing data disables highlighting without preventing audio.

Each backend origin gets its own v4 SQLite file and catalog cache, preventing
prelive/production or legacy proxy responses from being mixed. The previous
`quran_app.sqlite` file is preserved; v4 content is downloaded into the new cache.
Settings remain stored in shared preferences. Word layout cache keys now include
mushaf ID, keeping V2 and V4 Tajweed separate even though both use code_v2.
The schema 1-to-2 migration preserves fonts and treats unidentified legacy word
layouts as unavailable until reloaded.

Prelive currently returns only chapters 1 and 2. During integration checks,
page-1 requests for mushaf 1 and 2 returned empty verse lists, and mushaf 19
returned 404. Flutter displays a retryable unavailable-page message and does not
mark these pages as downloaded. Production provides populated layouts; the live integration test below verifies
that Flutter can parse and store them.

Backend deployment instructions are in `backend/README.md`.

Optional live integration check (requires network access):

```sh
flutter test --dart-define=QURAN_LIVE_TEST=true test/quran_api_live_test.dart
```

This verifies chapters, the chapter-reciter catalog, and timed audio responses.
Production verification also checks all 114 chapters and persists V1, V2,
and Tajweed page layouts into SQLite (including V1 pages 175 and 604):

```sh
flutter test --dart-define=QURAN_LIVE_TEST=true --dart-define=QURAN_PRODUCTION_TEST=true test/quran_api_live_test.dart
```

The prelive page-layout limitation above does not affect production.
