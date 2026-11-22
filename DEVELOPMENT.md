# Development Guide

## Required software

| Tool | Purpose |
|------|---------|
| Git | Version control |
| Flutter (includes Dart) | Application framework |
| Visual Studio Code | Editor (Flutter and Dart extensions) |
| Android Studio | Android SDK, emulator, build tools |
| Supabase account | Auth, database, storage |

Links: [Flutter](https://docs.flutter.dev/get-started/install), [VS Code](https://code.visualstudio.com/), [Android Studio](https://developer.android.com/studio), [Supabase](https://supabase.com/).

## Environment setup

1. Install Git and confirm `git --version` works.
2. Install Flutter and add it to your PATH.
3. Install VS Code plus the Flutter and Dart extensions.
4. Install Android Studio and the Android SDK.
5. Accept Android licences:
   ```bash
   flutter doctor --android-licenses
   ```
6. Verify everything:
   ```bash
   flutter doctor -v
   flutter devices
   ```
7. Connect an Android phone with USB debugging, or create an emulator, and confirm it appears in `flutter devices`.

Resolve all required Android toolchain issues before continuing.

## Flutter commands

```bash
flutter pub get              # install dependencies
flutter run                  # run on the selected device
flutter run -d chrome        # run on web
flutter run -d windows       # run on Windows
flutter analyze              # static analysis
flutter test                 # unit and widget tests
flutter clean                # clear build output
```

## Code-formatting rules

- Format with `dart format .` before every commit.
- CI enforces `dart format --output=none --set-exit-if-changed .`.
- `flutter analyze` must pass with no errors or warnings.
- Prefer immutable data models and `const` constructors.
- Keep screens presentation-only; business rules go in services or domain classes; database calls go in repositories.

## Branch and commit conventions

- `main` is always buildable. Do not commit broken code to it.
- Work on short-lived branches: `feat/<topic>`, `fix/<topic>`, `chore/<topic>`, `docs/<topic>`.
- Use Conventional Commits:
  - `feat: add dictionary search`
  - `fix: correct plural handling`
  - `chore: create Flutter application`
  - `docs: update development guide`
  - `test: add answer evaluation tests`
- Open a pull request for each branch and wait for CI to pass before merging.

## Local development instructions

1. Clone the repository and open it in VS Code.
2. Run `flutter pub get`.
3. Create a Supabase project. Provide the project URL and **public anon key** through local environment configuration (see `.env.example` once added).
4. Never put a Supabase service-role key or any private secret in the Flutter app or the repository.
5. Run the app with `flutter run`.
6. Before each commit:
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```

## Application ID

Set the permanent organisation ID (replace `com.example`) before the first public release. Do not change it casually afterwards.
