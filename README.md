# German Learning Platform (A1–C2)

A cross-platform Flutter application for learning German across CEFR levels A1 to C2.

> **Repository status:** The Flutter foundation, Supabase email/password authentication, learner profiles, CEFR onboarding and learner dashboard are implemented. PR #11 added the first offline Dart grammar-analysis engine; PR #12 is now merged as `e1ba8a9`, adding the modular A1 rule engine, selected present-tense agreement checks, conservative case-aware article compatibility and regression tests. The expanded A1 curriculum is being reconciled with the latest `main` in a follow-up pull request; it adds 10 units, 20 lessons and 60 practice items. The optional LanguageTool adapter remains draft in [PR #10](https://github.com/Pratham-1171/Deutsch-Guide/pull/10) and is not deployed or integrated into Flutter. On-device NLP is the primary offline path; the Dart rules are a limited foundation, not a complete German grammar checker.

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

### On-device German NLP (offline-first)

- Dart rule engine for local tokenisation, selected lemmatisation/POS hints and conservative A1–B1 grammar feedback
- Learner-facing offline checker at `/grammar`
- Optional ONNX Runtime Mobile model adapter planned only after German model licensing, Android operator compatibility and device benchmarks are verified
- Supabase remains responsible for authentication and progress sync; learner text is not sent to the server for local analysis
- The current rule engine is deliberately limited and does not claim complete German grammar correction or statistical parsing

See [On-device German NLP architecture](docs/ON_DEVICE_GERMAN_NLP.md) for implementation scope, validation status and model acceptance criteria.

### Optional online German NLP service

- Python and FastAPI for a separately deployed NLP API
- spaCy 3.8.18 with the CPU-oriented German `de_core_news_sm` 3.8.0 pipeline for tokenization, lemmatization, part-of-speech, morphology and syntax
- LanguageTool for spelling and grammar suggestions (candidate; not integrated yet)
- OpenThesaurus and other licence-approved lexical resources for word relations
- Sentence Transformers or another benchmarked German-capable embedding model for semantic similarity
- Optional LLM provider integration for tutor conversations and controlled content assistance
- Docker-based deployment, with the service hosted in or near the Supabase Mumbai region where practical

The Python spaCy service remains an optional online integration. The on-device Dart engine works without it. ONNX inference, lexical datasets, semantic evaluation, LLM and speech technologies remain candidates subject to licence, compatibility and quality review. See `services/german-nlp/THIRD_PARTY_NOTICES.md` for model provenance and licensing notes. The Flutter application must never contain server-side secrets or model-provider keys.

## German NLP architecture and integration flow

The application keeps Flutter as the presentation/client layer and Supabase as the identity and learner-data platform. German NLP runs locally by default; the Python service is optional.

```text
Flutter app (Android / Web / Windows)
        |
        +--> Local Dart German NLP + curriculum-aware grammar rules
        |       +--> tokenisation and selected lemmas/POS hints
        |       +--> offline grammar feedback and explanations
        |       +--> optional future ONNX Runtime Mobile model
        |
        +--> Supabase Auth / PostgreSQL / RLS (identity and progress sync)
        |
        `--> Optional online FastAPI service (spaCy / LanguageTool adapters)
                only when explicitly enabled and available
```

### Request flow

1. The learner enters German text in the Flutter app.
2. The on-device Dart NLP engine analyses it locally; no network request or learner-text upload is required.
3. Flutter displays rule findings, offsets and explanations.
4. Supabase is used separately for authentication and permitted progress synchronisation.
5. An optional remote NLP adapter may be enabled in a future release; it must authenticate requests, enforce limits and return versioned responses without persisting raw learner text by default.

### Planned NLP capabilities

- **Sentence analysis:** tokenization, lemmas, part of speech, morphology, verb forms and syntax.
- **Vocabulary intelligence:** articles, plurals, conjugations, synonyms, antonyms, word families, collocations and contextual examples.
- **Grammar and writing feedback:** spelling, grammar, word order, case and learner-friendly explanations.
- **Semantic answer evaluation:** identify plausible equivalent answers without treating similarity as proof of grammatical correctness.
- **Exercise intelligence:** create and validate level-constrained tasks using approved vocabulary and grammar content.
- **AI tutor:** guided conversations and explanations using controlled prompts and curriculum context.
- **Speech extensions:** transcription, listening and pronunciation feedback in a later stage.

### Integration principles

- Keep the on-device Dart engine as the default analysis path. Never ship service-role credentials, provider keys or privileged NLP secrets in Flutter. Optional remote processing must be explicitly enabled and must not block offline learning.
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

**Current status:** The primary shipped path is the local Dart A1 rules engine, now modularised in PR #12. It provides limited tokenisation, selected verb agreement, conservative article-form compatibility, capitalisation and a narrow word-order check. It is not a complete grammar checker. A separate authenticated FastAPI/spaCy sentence-analysis service exists in the repository but is not deployed or required by the app. LanguageTool remains an optional, unmerged adapter; no paid hosting or online NLP dependency is part of the current offline-first release.

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
- [Phase 6 plan — complete A1 curriculum](docs/PHASE_6_PLAN.md)

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
