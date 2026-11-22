# Development Guide

Phase 2 adds the initial Flutter application foundation. The code has not yet been compiled or tested with Flutter, so run the checks below locally before building on it.

## Required software

| Tool | Purpose |
|------|---------|
| Git | Version control |
| Flutter (includes Dart) | Application framework |
| Visual Studio Code | Editor with Flutter and Dart extensions |
| Android Studio | Android SDK, emulator and build tools |
| Supabase account | Authentication, database, storage and backend services |

Useful links: [Flutter installation](https://docs.flutter.dev/get-started/install), [Visual Studio Code](https://code.visualstudio.com/), [Android Studio](https://developer.android.com/studio) and [Supabase](https://supabase.com/).

## First run

From the repository root:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

The app currently opens a temporary dashboard. Its feature routes lead to placeholder screens until the corresponding phases are implemented.

## Supabase configuration

Supabase initialisation is optional. Without configuration, the app starts without connecting to a backend.

To enable it, pass the project URL and public anon key using Dart defines:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Only the public anon key belongs in the client. Never put a Supabase service-role key or other private credential in the Flutter app or Git repository.

## Code quality

- Run `dart format .` before committing.
- Resolve errors and warnings reported by `flutter analyze`.
- Run `flutter test` and add tests for new behaviour.
- Prefer immutable data models and `const` constructors where appropriate.
- Keep screens focused on presentation. Place business rules in domain or service classes and data access in repositories.

## Branch and commit conventions

- Keep `main` in a buildable state as the application grows.
- Use short-lived branches such as `feat/dictionary-search`, `fix/answer-validation`, `chore/flutter-scaffold` and `docs/development-guide`.
- Use Conventional Commit messages, for example:
  - `feat: add dictionary search`
  - `fix: correct plural handling`
  - `chore: create Flutter application`
  - `docs: update development guide`
  - `test: add answer evaluation tests`
- Open a pull request for each feature or fix and run CI before merging.

## Application identifier

Choose the permanent Android application ID / organisation identifier before the first public release. Avoid changing it after publication because it can affect app identity and upgrades.
