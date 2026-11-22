# Development Guide

Phase 2 adds the Flutter application foundation. Phase 3 adds Supabase email/password authentication and session-based routing. The merged implementation passed Dart formatting, `flutter analyze`, and all three current widget tests in GitHub Actions on Flutter 3.50.1. Physical-device auth callback flows and platform builds still require verification.

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
dart format --output=none --set-exit-if-changed lib test
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

These Auth flows do not require application tables. Add and review Row Level Security policies before introducing user-owned application data.

## Next milestone

See [docs/PHASE_4_PLAN.md](docs/PHASE_4_PLAN.md) for the Phase 4 scope: platform setup, auth end-to-end verification, a minimal RLS-protected learner profile, profile onboarding, and a personalized dashboard. The plan deliberately delays curriculum engines and progress tracking until those foundations are stable.

## Code quality

- Run the CI formatting check before committing.
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
