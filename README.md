# German Learning Platform (A1–C2)

A cross-platform app for learning German along the CEFR levels A1 to C2, with student and teacher accounts, a searchable dictionary, and German text-to-speech.

## Supported platforms

- Android
- Web
- Windows desktop

## Main features

- CEFR learning paths (A1–C2)
- Reading, listening, writing, speaking, vocabulary, grammar, verbs and practice
- Searchable German dictionary
- German text-to-speech and listening audio
- Student and teacher accounts, assignments and feedback
- Progress tracking and spaced repetition

## Technology stack

- Flutter / Dart
- Riverpod (state) and GoRouter (navigation)
- Supabase (authentication, PostgreSQL, storage, functions)
- Local SQLite for offline content and progress
- GitHub Actions for CI and builds

## Setup

1. Install Git, Flutter, VS Code and Android Studio (see `docs/DEVELOPMENT.md`).
2. Clone this repository.
3. Create a Supabase project and add its URL and public anon key to your local environment configuration. Never commit secrets or a service-role key.
4. Install dependencies and run:

```bash
flutter pub get
flutter run
```

## Run tests

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Build release versions

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build windows --release
```

See `docs/RELEASES.md` for signing and release procedures.

## Documentation

- `docs/DEVELOPMENT.md`: development setup and conventions

## License

See `LICENSE`.
