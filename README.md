# German Learning Platform (A1–C2)

A cross-platform application for learning German across CEFR levels A1 to C2.

> **Repository status:** This repository currently contains project documentation only. The Flutter application source, including `pubspec.yaml`, `lib/`, platform folders and tests, has not been added yet. The setup, test and build commands below become usable after the application scaffold is committed.

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

## Intended technology stack

- Flutter / Dart
- Riverpod for state management
- GoRouter for navigation
- Supabase for authentication, PostgreSQL, storage and backend functions
- GitHub Actions for continuous integration and builds

## Development setup

1. Install Git, Flutter (including Dart), Visual Studio Code and Android Studio.
2. Clone this repository.
3. Install Flutter dependencies from the project root once `pubspec.yaml` has been added:
   ```bash
   flutter pub get
   ```
4. Configure the Supabase project URL and public anon key using the app's documented local configuration. Never commit credentials, private keys or a Supabase service-role key.
5. Start the app on a connected device:
   ```bash
   flutter run
   ```

See [DEVELOPMENT.md](DEVELOPMENT.md) for the development workflow.

## Quality checks

Run these from the project root after the Flutter application scaffold and tests are present:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Release builds

After the relevant platform targets have been configured:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build windows --release
```

See [RELEASES.md](RELEASES.md) for release preparation and signing guidance.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
