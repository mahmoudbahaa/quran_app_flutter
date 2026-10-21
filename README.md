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

The database test checks cached font persistence after reopening SQLite. The
schema remains at version 1; generated Dart model names do not alter SQL tables.
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
forcing these with dependency overrides.
