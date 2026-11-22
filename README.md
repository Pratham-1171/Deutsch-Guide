# German Learning Platform (A1–C2)

A cross-platform Flutter application for learning German across CEFR levels A1 to C2.

> **Repository status:** Phase 2 Flutter foundation and Phase 3 Supabase authentication are merged into `main`. GitHub Actions on Flutter 3.50.1 passed Dart formatting, static analysis and all three current widget tests. Android, Web and Windows platform projects, end-to-end email flows, profile data and curriculum features are still to be completed.

## Planned platforms

- Android
- Web
- Windows desktop

## Planned learning features

- CEFR learning paths (A1–C2)
- Reading, listening, writing and speaking practice
- Vocabulary, grammar, verbs and exercises
- Searchable German dictionary
- German text-to-speech and listening audio
- Learning progress and spaced repetition

## Technology

- Flutter / Dart
- Riverpod for state management
- GoRouter for navigation and authentication redirects
- Supabase for authentication, PostgreSQL, storage and backend functions
- GitHub Actions for continuous integration and builds

## Development setup

1. Install Git, Flutter (including Dart), Visual Studio Code and Android Studio.
2. Clone this repository and open its root directory.
3. Install the dependencies declared in `pubspec.yaml`:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

The app starts without Supabase configuration and displays the temporary dashboard. To connect the live Supabase project, pass its URL and public publishable key at build time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://egjtrbxjvrdsgsamvctc.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SB_PUBLISHABLE_KEY
```

Replace the placeholder with the project's `sb_publishable_...` key. Never place a Supabase secret or service-role key in the Flutter client or Git repository. The publishable key is not a substitute for Row Level Security.

## Authentication

Phase 3 provides email/password registration, sign-in, password reset, sign-out and session-based route guards. See [AUTH_SETUP.md](AUTH_SETUP.md) for email-provider, redirect URL and mobile deep-link configuration. The auth flows have passed CI widget checks; physical-device email confirmation and recovery still need end-to-end verification.

## Roadmap

- [Phase 4 plan — platform readiness and learner profile](docs/PHASE_4_PLAN.md)
- Phase 5 preview: versioned curriculum format and the first complete A1 learning path.

## Quality checks

Run these checks before opening a pull request:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The current CI run passed these checks on Flutter 3.50.1.

## Release builds

Platform targets must be generated/configured before release builds are available:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build windows --release
```

See [RELEASES.md](RELEASES.md) for release preparation and signing guidance.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
