# Supabase Authentication Setup

This guide configures the Flutter app's email/password authentication with the Supabase project **german-learning-platform**.

## Project details

- Project ref: `egjtrbxjvrdsgsamvctc`
- Region: Mumbai (`ap-south-1`)
- API URL: `https://egjtrbxjvrdsgsamvctc.supabase.co`

The Flutter client uses the project's publishable key through a build-time Dart define. Never use a secret key or service-role key in the app.

## 1. Configure the email provider

In the Supabase Dashboard:

1. Open **Authentication → Providers → Email**.
2. Ensure email/password sign-up is enabled.
3. Choose whether email confirmation is required. When it is enabled, a new user must confirm their address before signing in.
4. For production, configure a trusted custom SMTP provider under **Project Settings → Authentication → SMTP Settings**. Supabase's default email service is intended for limited testing.

The app supports both confirmation modes. If confirmation is required, sign-up displays a check-your-inbox message and waits for the user to confirm.

## 2. Add the redirect URL

Open **Authentication → URL Configuration** and add this value to **Redirect URLs**:

```text
deutschguide://auth-callback/
```

For Flutter Web, configure the deployed web URL as the Supabase **Site URL** and add local development URLs (for example `http://localhost:*`) to the allowed redirect list as appropriate.

## 3. Register the mobile URL scheme

The repository currently contains the Flutter Dart source but does not yet include generated platform folders. After generating Android/iOS platforms with Flutter, register the custom URL scheme.

### Android

In `android/app/src/main/AndroidManifest.xml`, add this intent filter inside the main Flutter activity:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="deutschguide"
        android:host="auth-callback" />
</intent-filter>
```

### iOS

In `ios/Runner/Info.plist`, add the scheme under `CFBundleURLTypes`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>deutschguide</string>
        </array>
    </dict>
</array>
```

Supabase Flutter listens for auth deep links and emits auth-state events. The app uses the password-recovery event to show the new-password form.

## 4. Run the app

From the repository root:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://egjtrbxjvrdsgsamvctc.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SB_PUBLISHABLE_KEY
```

Replace the placeholder with the active `sb_publishable_...` value from **Project Settings → API Keys**. Do not put the value in source files, commits, screenshots, or public logs.

## 5. Available authentication flows

- Create an account using display name, email and password.
- Sign in with email and password.
- Send a password reset email.
- Complete a password reset after opening the app callback.
- Sign out from the dashboard.
- Redirect signed-out users to sign-in when Supabase is configured.
- Return signed-in users to the dashboard when they open sign-in/sign-up screens.

When the app is run without Supabase Dart defines, the temporary dashboard and placeholder routes remain usable and auth pages show a configuration note.

## Security notes

- The publishable key identifies the client; it is not an authorization boundary.
- Do not expose secret or service-role keys in Flutter or GitHub.
- Any future user-owned tables must have Row Level Security enabled and ownership policies reviewed before they are exposed through the Data API.
- Do not use user-editable Auth metadata to grant roles or permissions.
