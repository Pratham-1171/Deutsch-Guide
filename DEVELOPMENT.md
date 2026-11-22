# Development Guide

Phase 2 established the Flutter foundation and Phase 3 added Supabase email/password authentication. Phase 4 adds generated Android, Web and Windows projects, a learner-owned profile schema, CEFR onboarding and a personalised dashboard. GitHub Actions validates formatting, analysis, tests and platform builds; physical-device email-link flows remain a manual verification step.

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

See [AUTH_SETUP.md](AUTH_SETUP.md) for the Email provider, redirect URL and Android intent filter settings. Add `deutschguide://auth-callback/` to the Supabase redirect allow-list and verify confirmation and password-recovery links on a real Android device.

The app currently supports:
- Email/password sign-up with optional email confirmation.
- Email/password sign-in and sign-out.
- Password reset email requests and password updates from the recovery session.
- Route redirects for signed-out and signed-in users.

These Auth flows do not require application tables. Add and review Row Level Security policies before introducing user-owned application data.

## Current milestone

See [docs/PHASE_4_PLAN.md](docs/PHASE_4_PLAN.md) for the Phase 4 acceptance criteria and remaining manual checks. The first profile migration is in `supabase/migrations/`; its structural security assertions are in `supabase/tests/profiles_security.sql`. Apply later migrations in version order and keep the migration filenames aligned with the versions recorded by Supabase. Curriculum engines and learner progress tracking are intentionally deferred to Phase 5.

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

The Android application ID is `com.pratham1171.deutsch_guide`. It was generated from the repository owner namespace and project name. Treat it as permanent after the first public release; changing it later affects app identity and upgrade paths.
