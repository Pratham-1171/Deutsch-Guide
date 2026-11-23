# Phase 5 Plan — Curriculum and First A1 Learning Path

## Goal

Replace the temporary learning-area placeholders with the first real, data-driven German course. Establish a versioned curriculum format that can later support A1–C2 without tying lesson content to Flutter widgets or adding premature progress tables.

## Confirmed starting point

- Phase 2 Flutter foundation and Phase 3 Supabase email/password authentication are on `main`.
- The learner profile, CEFR onboarding and learner dashboard are present in the current application.
- Android sign-in and system Back navigation have been manually confirmed by the project owner.
- The current learning-area and lesson routes still lead to placeholder screens.
- The repository roadmap preview calls for a versioned curriculum format and the first complete A1 path.

## Phase 5 workstreams

### 5.1 — Curriculum contract and content repository

- Define a versioned, locale-independent curriculum document format.
- Give every level, unit, lesson, objective and exercise a stable ID.
- Keep authored content as reviewable JSON in the repository.
- Validate required fields, unique IDs, supported exercise types and references.
- Separate content data from presentation and scoring logic.
- Start with German A1; preserve a clean extension path for A2–C2.

**Acceptance criteria**
- Curriculum files declare a schema/content version and CEFR level.
- Invalid content fails validation with a useful error.
- Content can be loaded in tests without Supabase or network access.
- No learner progress schema is added in this workstream.

### 5.2 — First A1 learning path

Create a coherent A1 beginner path with units, lessons, learning objectives and short practice tasks. Content should progress from introductions and personal information through everyday situations. German examples must be natural and grammatically correct; instructions should use clear, beginner-friendly English.

Each lesson should include:
- A short, measurable objective.
- A concise explanation or phrase/chunk set.
- Examples with English meaning.
- Practice items with one unambiguous correct answer.
- A brief explanation for the answer.

**Acceptance criteria**
- The A1 path is complete enough to navigate from its first unit to its final planned unit.
- Every lesson has at least one objective and practice activity.
- Every exercise has a stable ID, prompt, answer key and feedback.
- Content review can happen in Git diffs without editing Dart code.

### 5.3 — Reusable lesson experience

- Build a course-level screen listing units and lessons.
- Build a reusable lesson player driven by curriculum data.
- Support the first exercise types only (single-choice and typed short answer).
- Show progress within the current lesson session and clear answer feedback.
- Handle loading, empty, malformed-content and completion states.
- Keep navigation accessible on small Android screens and Web.

**Acceptance criteria**
- A learner can open A1, select a unit and lesson, answer its activities and reach a completion screen.
- The same player renders different lessons from data rather than lesson-specific widgets.
- Lesson completion is session-only until its persistence model is explicitly designed.

### 5.4 — Testing and release gate

- Unit-test curriculum parsing and validation.
- Test exercise answer checking, including case and whitespace handling where appropriate.
- Widget-test unit listing, lesson navigation, exercise feedback and completion.
- Run format, analyze, tests, Android debug build and Web build in CI.
- Update README and development documentation.

## Data and architecture rules

- Keep authored curriculum content in the repository and version it explicitly.
- Do not put course content into a Supabase table in this phase.
- Do not add lesson completion, streaks, mastery analytics or spaced-repetition tables until their semantics and data ownership are designed.
- Do not add offline-first sync, social login, admin/teacher role management, or translation features.
- Never put service-role credentials in the Flutter app.
- Preserve the existing authentication, learner profile and dashboard behaviour.

## Delivery order

1. Commit this phase plan and curriculum contract.
2. Add the curriculum domain model, loader and validator with tests.
3. Author and validate the complete A1 curriculum dataset.
4. Replace the level placeholder with a data-driven unit/lesson catalogue.
5. Implement the reusable lesson player and first exercise types.
6. Add widget tests, run CI, review the generated APK, and ask for on-device verification.
