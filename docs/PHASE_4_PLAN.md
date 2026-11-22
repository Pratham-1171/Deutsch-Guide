# Phase 4 Plan — Platform Readiness and Learner Profile

## Goal

Turn the Phase 2–3 Flutter foundation into a usable, authenticated learner starting point. By the end of Phase 4, a learner should be able to open the app on a supported platform, create or sign in to an account, complete a short profile setup, choose a CEFR starting level, and reach a personalized dashboard.

This phase establishes the data ownership and platform foundations needed before lesson content and progress features are added.

## Current baseline

- Flutter foundation, Riverpod, GoRouter and light/dark theme are in place.
- Supabase publishable-key configuration is in place.
- Email/password sign-up, sign-in, password reset, sign-out and session route guards are implemented.
- CI on Flutter 3.50.1 passed Dart formatting, static analysis and all six tests (three widget tests and three learner-profile unit tests).
- The Supabase project `german-learning-platform` is healthy in Mumbai (`ap-south-1`).
- The `public.profiles` table is deployed with RLS, a signup trigger, column-limited profile updates and a backfill for existing Auth users.
- Supabase security advisor returned no findings after explicit trigger-function execution grants were revoked.
- Android, Web and Windows folders are not yet committed; a one-time workflow generates and validates them after the implementation PR is merged.
- Email confirmation and password reset have not yet been verified end-to-end on a physical device.

## Implementation status (2026-11-22)

- The profile schema and its follow-up trigger-function privilege migration are applied to the connected Supabase project.
- Flutter profile model, repository, Riverpod providers, onboarding form, learner dashboard and profile-based route gate are included in the Phase 4 implementation branch.
- Profile model tests and structural database security assertions have been added.
- Physical Android email-confirmation/password-recovery testing and real Web sign-in/session testing remain outstanding.

## Scope

### 4.1 — Generate and configure platform projects

Create the Flutter platform folders needed by the planned product targets:

- Android
- Web
- Windows

Before generating Android release identifiers, choose and record the permanent Android application ID. Do not guess or silently change the application ID after the first distributed build.

Configure the Android deep-link intent filter for:

```text
deutschguide://auth-callback/
```

Keep the Supabase redirect allow-list and platform callback configuration consistent with `AUTH_SETUP.md`. Configure Web to use the deployed site URL. Add desktop protocol registration only when implementing desktop auth callbacks is in scope.

**Acceptance criteria**
- `flutter run -d <android-device>` launches the app.
- `flutter run -d chrome` launches the Web target.
- The Windows project is generated and builds on a supported Windows runner.
- Android email-confirmation and password-recovery links return to the app.
- No publishable key, secret key, keystore, or password is committed to the repository.

### 4.2 — Complete authentication verification

Test the existing flows against the live Supabase Auth service using a dedicated test account:

- Sign up with email and password.
- Confirm email when email confirmation is enabled.
- Sign in and restore an existing session after app restart.
- Sign out and verify protected routes redirect to sign-in.
- Request a password reset and complete it through the recovery callback.
- Verify errors for invalid credentials, expired links, and network failure.

Add integration coverage where practical. CI tests must not depend on a real user's mailbox or production credentials; keep live-service smoke tests manual or in a separate secured environment.

**Acceptance criteria**
- All listed flows work on Android.
- Sign-in and session restoration work on Web.
- Invalid and expired callback links show a safe, understandable error state.
- CI remains deterministic without Supabase secrets.

### 4.3 — Add a minimal learner profile schema

Create the first versioned Supabase migration for `public.profiles`.

Proposed fields:

| Field | Type | Purpose |
|---|---|---|
| `id` | `uuid primary key` | Same value as `auth.users.id`; cascade on user deletion |
| `display_name` | `text` | Learner-facing name |
| `current_level` | `text` | CEFR level, constrained to A1, A2, B1, B2, C1 or C2 |
| `created_at` | `timestamptz` | Creation timestamp |
| `updated_at` | `timestamptz` | Last update timestamp |

Use a signup trigger to create the profile from the display name supplied at registration, with a safe fallback. Keep the trigger function narrowly scoped, use a fixed search path, and avoid trusting user-editable metadata for permissions.

Enable Row Level Security and add only the policies required for the learner:
- A signed-in user can read their own profile.
- A signed-in user can update their own profile.
- A user cannot read or update another user's profile.
- The client cannot set privileged role or permission fields; no such fields are part of this phase.

Add migration tests or SQL checks for ownership boundaries. Run the Supabase security advisor after applying the migration.

**Acceptance criteria**
- Migration is committed in `supabase/migrations/`.
- A new Auth user receives exactly one matching profile.
- RLS blocks cross-user profile reads and writes.
- No service-role or secret key is used by the Flutter client.

### 4.4 — Build profile onboarding

Add a profile repository, immutable profile model, and Riverpod providers.

After the first successful sign-in:
- If the profile is incomplete, show a short onboarding screen.
- Allow the learner to confirm their display name.
- Allow the learner to choose a starting CEFR level from A1 through C2.
- Save the profile through the authenticated Supabase client.
- Return the learner to the dashboard after successful save.

Keep profile loading, empty, saving, validation, and error states explicit. Do not store profile data in a second client-side database.

**Acceptance criteria**
- New users see onboarding once.
- Returning users with a complete profile go directly to the dashboard.
- Profile changes are persisted and reloaded from Supabase.
- A failed save can be retried without losing form input.

### 4.5 — Replace the temporary dashboard with a learner home

Build the first real learner dashboard using the authenticated profile:

- Greeting with the learner's display name.
- Current CEFR level and a clear continue-learning entry point.
- Cards or navigation links for the existing learning areas.
- A visible profile/settings entry point and sign-out action.
- Proper loading and retry states when profile data cannot be loaded.

Curriculum and lesson pages may remain clearly marked as not yet available; do not fill them with invented lesson content.

**Acceptance criteria**
- Dashboard displays data from the current user's profile.
- Direct navigation to protected routes remains guarded.
- Dashboard adapts to light and dark themes and small mobile screens.
- The no-Supabase demo mode continues to work for UI development.

## Recommended implementation order

1. Generate platform folders and register Android auth deep links.
2. Verify sign-up, email confirmation, session restoration and password recovery on Android and Web.
3. Add the `profiles` migration, signup trigger and RLS policies.
4. Add the profile model, repository and Riverpod providers.
5. Add first-run onboarding and CEFR level selection.
6. Replace the temporary dashboard with the personalized learner home.
7. Add unit, widget, migration/RLS and integration tests; keep CI green.
8. Update README, AUTH_SETUP.md and DEVELOPMENT.md with the verified setup.

## Explicitly out of scope

- Full grammar, vocabulary, reading, listening, writing or speaking lesson engines.
- Bulk curriculum import or dictionary ingestion.
- Lesson completion, streaks, mastery analytics or spaced repetition.
- Social sign-in providers.
- Paid subscriptions or billing.
- Background synchronization or offline-first storage.
- Privileged roles and role-management interfaces.

These can be planned as later phases once the first authenticated learner flow is stable.

## Phase 4 release gate

Phase 4 is complete only when:
- Android auth deep links and password recovery have been tested on a device.
- Web sign-in works with the configured site URL.
- A learner profile is created, read and updated through RLS-protected access.
- Onboarding and the personalized dashboard work for both new and returning users.
- `dart format`, `flutter analyze`, `flutter test` and applicable integration checks pass.
- Supabase security advisor findings introduced by the migration are resolved.
- No private credentials are present in Git history.

## Next phase preview — Phase 5

After Phase 4, design a versioned curriculum content format and implement the first complete A1 learning path: levels, units, lessons, lesson objectives, exercises and a reusable lesson player. Keep authored course content reviewable in the repository, and only introduce learner progress tables once the lesson-completion model is defined.
