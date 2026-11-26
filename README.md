# German Learning Platform (A1–C2)

A cross-platform Flutter application for learning German across CEFR levels A1 to C2.

> **Repository status:** The Flutter foundation, Supabase email/password authentication, learner profiles, CEFR onboarding and learner dashboard are implemented. The expanded A1 curriculum is being developed in [PR #8](https://github.com/Pratham-1171/Deutsch-Guide/pull/8); it is not part of `main` until that PR is merged. The German NLP work is currently in the planning/documentation stage. No NLP service or NLP database migrations have been deployed.

## Planned platforms

- Android
- Web
- Windows desktop

## Learning features

- CEFR learning paths (A1–C2)
- Reading, listening, writing and speaking practice
- Vocabulary, grammar, verbs and exercises
- Searchable German dictionary
- German text-to-speech and listening audio
- Learning progress and spaced repetition
- NLP-assisted sentence analysis, grammar feedback and answer evaluation
- Contextual vocabulary learning and adaptive exercises
- AI-supported German conversation practice

## Technology

### Existing application

- Flutter / Dart
- Riverpod for state management
- GoRouter for navigation and authentication redirects
- Supabase for authentication, PostgreSQL, storage and backend functions
- GitHub Actions for continuous integration and builds

### Planned online German NLP service

- Python and FastAPI for a separately deployed NLP API
- spaCy for German tokenization, lemmatization, part-of-speech and syntactic analysis
- LanguageTool for spelling and grammar suggestions
- OpenThesaurus and other licence-approved lexical resources for word relations
- Sentence Transformers or another benchmarked German-capable embedding model for semantic similarity
- Optional LLM provider integration for tutor conversations and controlled content assistance
- Docker-based deployment, with the service hosted in or near the Supabase Mumbai region where practical

The NLP service is a planned online component. These are candidate technologies, not yet approved runtime dependencies. Exact package/model versions, dataset licences, hosting costs and quality benchmarks must be reviewed before implementation. The Flutter application must never contain server-side secrets or model-provider keys.

## German NLP architecture and integration flow

The application will keep Flutter as the presentation/client layer, Supabase as the identity and learner-data platform, and German NLP processing in a separate Python service.

```text
Flutter app (Android / Web / Windows)
        |
        | HTTPS + Supabase user access token
        v
Supabase Auth ----------------------+
        |                           |
        | JWT verification          | PostgreSQL / RLS
        v                           v
Python FastAPI German NLP service -> Learner data,
        |                            attempts and mastery
        |
        +--> spaCy: sentence and morphology analysis
        +--> LanguageTool: spelling and grammar feedback
        +--> lexical resources: vocabulary and word relations
        +--> semantic model: meaning similarity and answer evaluation
        +--> optional LLM: tutor and constrained generation
        |
        v
Structured, versioned JSON response
        |
        v
Flutter learning features
```

### Request flow

1. A learner signs in through Supabase Auth.
2. Flutter sends an HTTPS request to the NLP API with the user's Supabase access token.
3. The API validates the JWT and enforces request limits and input-size constraints.
4. The relevant NLP engine processes the text or exercise.
5. The API returns a versioned, structured response with findings, explanations, confidence and engine metadata where applicable.
6. Flutter displays the feedback. Persistent learner records are written only through authenticated, RLS-protected data access or narrowly scoped server-side operations.
7. The service records operational metrics without retaining unnecessary raw learner text.

### Planned NLP capabilities

- **Sentence analysis:** tokenization, lemmas, part of speech, morphology, verb forms and syntax.
- **Vocabulary intelligence:** articles, plurals, conjugations, synonyms, antonyms, word families, collocations and contextual examples.
- **Grammar and writing feedback:** spelling, grammar, word order, case and learner-friendly explanations.
- **Semantic answer evaluation:** identify plausible equivalent answers without treating similarity as proof of grammatical correctness.
- **Exercise intelligence:** create and validate level-constrained tasks using approved vocabulary and grammar content.
- **AI tutor:** guided conversations and explanations using controlled prompts and curriculum context.
- **Speech extensions:** transcription, listening and pronunciation feedback in a later stage.

### Integration principles

- Keep NLP processing outside the Flutter client; do not ship Python models or privileged credentials in the app.
- Keep the authored curriculum as versioned, reviewable content and treat it as the educational source of truth.
- Use deterministic rules and curated answer keys for exact grammar tasks; use semantic models only where meaning-based evaluation is appropriate.
- Apply CEFR constraints and human-reviewed quality tests to generated content.
- Require JWT verification, RLS, rate limits, input validation, timeouts and safe error responses.
- Minimise retention of learner writing and tutor conversations; define retention and deletion rules before storing them.
- Cache only safe, non-user-specific analysis results unless cache isolation is explicitly designed.
- Verify the licence and permitted use of every package, model and dataset before adoption.
- Preserve existing authentication and learner flows; introduce changes incrementally behind tested API contracts.

### NLP implementation roadmap

The detailed scope, acceptance criteria and delivery gates are maintained in [German NLP Integration Plan](docs/GERMAN_NLP_INTEGRATION_PLAN.md).

1. **Phase 0 — Foundation:** compatibility review, licence register, CEFR data standards, API contracts and benchmark design.
2. **Phase 1 — Service infrastructure:** FastAPI, Docker, Supabase JWT verification, versioned endpoints, rate limiting, observability and deployment.
3. **Phase 2 — Linguistic engine:** German sentence tokenization, lemmatization, POS, morphology and syntax.
4. **Phase 3 — Vocabulary intelligence:** lexical data, word relations, inflections, examples and CEFR metadata.
5. **Phase 4 — Grammar and writing:** grammar service integration, error classification and learner-friendly feedback.
6. **Phase 5 — Semantic evaluation:** embeddings, answer equivalence, confidence thresholds and false-positive controls.
7. **Phase 6 — Exercise intelligence:** constrained generation, validation, ambiguity checks and answer-key tests.
8. **Phase 7 — AI tutor:** contextual conversations, safe provider integration and structured tutor responses.
9. **Phase 8 — Speech:** speech recognition, text-to-speech and pronunciation/listening workflows.
10. **Phase 9 — Flutter integration:** client repositories, feature screens, loading/error states and progressive rollout.
11. **Phase 10 — Production hardening:** security, CEFR quality benchmarks, load tests, monitoring and release validation.

**Current status:** Documentation and architecture planning only. No NLP runtime, API endpoint, model, dependency, database migration or cloud deployment has been added yet.

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

## Authentication and learner profile

The app provides email/password registration, sign-in, password reset, sign-out and session-based route guards. A new account receives a learner profile and is guided through display-name and CEFR-level onboarding. Profile data is read and updated through authenticated Supabase access with row-level security. See [AUTH_SETUP.md](AUTH_SETUP.md) for email-provider and redirect configuration. Physical-device email confirmation and recovery still need end-to-end verification.

## Roadmap and project documentation

- [Phase 4 plan — platform readiness and learner profile](docs/PHASE_4_PLAN.md)
- [Phase 5 plan — curriculum and first A1 learning path](docs/PHASE_5_PLAN.md)
- [German NLP integration plan — architecture, phases and acceptance criteria](docs/GERMAN_NLP_INTEGRATION_PLAN.md)
- [PR #8 — expanded A1 curriculum](https://github.com/Pratham-1171/Deutsch-Guide/pull/8)

## Quality checks

Run these checks before opening a pull request:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The Flutter CI workflow runs these checks and conditionally builds Android and Web when their platform folders are present.

## Release builds

The Android, Web and Windows project folders are generated by the platform scaffold workflow. Run release builds only after that workflow has completed:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build windows --release
```

See `RELEASES.md` for release preparation and signing guidance.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
