# Release Guide

This guide is a release checklist for when the Flutter application and platform projects have been added to the repository.

## Before a release

1. Confirm the intended release commit is on the release branch.
2. Run formatting, static analysis and automated tests:
   ```bash
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test
   ```
3. Test the app on the target devices and review permissions, navigation, accessibility and error states.
4. Confirm application version and build number are updated.
5. Review dependencies and ensure no credentials or private signing files are committed.

## Android release

- Configure the permanent Android application ID.
- Create and securely store the Android upload/release keystore.
- Keep keystore passwords and signing properties outside version control.
- Build the release artifacts:
  ```bash
  flutter build appbundle --release
  flutter build apk --release
  ```
- Test the signed artifact before distribution.
- Back up signing credentials securely; losing them can affect future app updates.

## Web release

Build the web application with:

```bash
flutter build web --release
```

Deploy the generated `build/web` directory to the chosen hosting provider. Configure any required routing fallback and environment settings in the hosting environment, not in committed secrets.

## Windows release

Build on a supported Windows host:

```bash
flutter build windows --release
```

Test the packaged application on a clean Windows machine and include any required runtime dependencies in the distribution instructions.

## GitHub Actions

- Store signing credentials and deployment tokens as repository or environment secrets.
- Never print secrets in workflow logs.
- Run formatting, analysis and tests before producing release artifacts.
- Upload build outputs as workflow artifacts or attach approved distributables to a GitHub Release.
- Do not publish a release until the relevant platform build and smoke tests pass.
