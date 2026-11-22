# Development Guide

This guide describes the intended development workflow for the Flutter application. The repository currently contains documentation only; complete the Flutter project scaffold before running project-specific Flutter commands.

## Required software

| Tool | Purpose |
|------|---------|
| Git | Version control |
| Flutter (includes Dart) | Application framework |
| Visual Studio Code | Editor with Flutter and Dart extensions |
| Android Studio | Android SDK, emulator and build tools |
| Supabase account | Authentication, database, storage and backend services |

Useful links: [Flutter installation](https://docs.flutter.dev/get-started/install), [Visual Studio Code](https://code.visualstudio.com/), [Android Studio](https://developer.android.com/studio) and [Supabase](https://supabase.com/).

## Environment setup

1. Install Git and confirm `git --version` works.
2. Install Flutter and add it to your PATH.
3. Install the Flutter and Dart extensions in Visual Studio Code.
4. Install Android Studio and the Android SDK.
5. Accept Android licences:
   ```bash
   flutter doctor --android-licenses
   ```
6. Verify the toolchain:
   ```bash
   flutter doctor -v
   flutter devices
   ```
7. Connect an Android phone with USB debugging enabled, or create an emulator, and confirm it appears in `flutter devices`.

Resolve the required toolchain issues for your target platform before building.

## Common Flutter commands

Run these from the repository root after `pubspec.yaml` and the Flutter source have been added:

```bash
flutter pub get              # install dependencies
flutter run                  # run on the selected device
flutter run -d chrome        # run on web
flutter run -d windows       # run on Windows (Windows host required)
flutter analyze              # static analysis
flutter test                 # unit and widget tests
flutter clean                # clear generated build output
```

## Code quality

- Run `dart format .` before committing.
- CI should enforce `dart format --output=none --set-exit-if-changed .`.
- Resolve all errors and warnings reported by `flutter analyze`.
- Prefer immutable data models and `const` constructors where appropriate.
- Keep screens focused on presentation. Place business rules in domain or service classes and data access in repositories.
- Add tests for domain logic, repositories and important widget behaviour.

## Branch and commit conventions

- Keep `main` in a buildable state once the application scaffold exists.
- Use short-lived branches such as `feat/dictionary-search`, `fix/answer-validation`, `chore/flutter-scaffold` and `docs/development-guide`.
- Use Conventional Commit messages, for example:
  - `feat: add dictionary search`
  - `fix: correct plural handling`
  - `chore: create Flutter application`
  - `docs: update development guide`
  - `test: add answer evaluation tests`
- Open a pull request for each feature or fix and run CI before merging.

## Supabase and secrets

- Use the Supabase project URL and public anon key through the app's local configuration.
- Never place a Supabase service-role key or other private credential in the Flutter client or Git repository.
- Keep local environment files out of version control. Update the setup documentation when the app's actual configuration mechanism is implemented.

## Application identifier

Choose the permanent Android application ID / organisation identifier before the first public release. Avoid changing it after publication because it can affect app identity and upgrades.
