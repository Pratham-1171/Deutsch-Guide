# Development Guide

Phase 2 adds the Flutter application foundation. Phase 3 adds Supabase email/password authentication and session-based routing. Flutter analysis, tests and builds have not yet been run in this environment, so validate locally before building further.

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

Without Supabase build-time values, the app keeps its temporary dashboard demo mode and shows a setup note on authentication screens.

## Supabase configuration

The app connects to the Supabase project `german-learning-platform` in Mumbai (`ap-south-1`). Pass the project URL and its **publishable** key at build time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://egjtrbxjvrdsgsamvctc.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SB_PUBLISHABLE_KEY
```

Replace the placeholder with the active `sb_publishable_...` key from Project Settings → API Keys. Do not put the actual key in source files or GitHub commits. Never use a Supabase secret or legacy service-role key in the Flutter client.

For release builds, pass the same defines to the relevant `flutter build` command.

## Authentication setup

See [AUTH_SETUP.md](AUTH_SETUP.md) for the Email provider, redirect URL, Android intent filter and iOS URL scheme settings. These settings must be completed in the Supabase Dashboard and generated platform folders before email confirmation and password recovery deep links can complete on device.

The app currently supports:
- Email/password sign-up with optional email confirmation.
- Email/password sign-in and sign-out.
- Password reset email requests and password updates from the recovery session.
- Route redirects for signed-out and signed-in users.

No application tables or database migrations are required for these Auth flows. Add and review Row Level Security policies before introducing user-owned application data.

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
