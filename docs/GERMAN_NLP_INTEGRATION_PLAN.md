# German NLP Integration Plan

## 1. Purpose

Build complete German NLP capability for Deutsch-Guide (A1–C2) while preserving the Flutter application and Supabase. The product priority is offline-first, on-device analysis: deterministic Dart rules are the default and must remain usable without hosting, payment cards or a network connection. A separately deployed Python service is optional future infrastructure, not a release dependency. Supabase remains responsible for identity and learner progress.

This document is the integration baseline. The initial service scaffold is being developed in `services/german-nlp`; it does not approve any third-party linguistic dataset/model, production hosting provider or production data-retention policy. Those require explicit technical and licence review.

## 2. Current repository baseline

The plan is based on the current `main` branch snapshot, with the implementation status below reflecting the separate integration branch.

- Flutter / Dart application.
- Riverpod state management and GoRouter navigation.
- Supabase Auth and PostgreSQL.
- Learner profile and CEFR onboarding flow.
- Versioned, JSON-based curriculum approach.
- GitHub Actions Flutter CI.

The expanded A1 curriculum remains open in PR #8 and must be reconciled with the merged on-device NLP engine before exercise-aware feedback is implemented. PR #12 has merged the modular offline A1 rule engine into main.

Current gaps relevant to NLP (before the initial service scaffold):

- No Python service or NLP deployment.
- No NLP client/API contract in Flutter.
- No dedicated NLP database schema.
- The first CPU-oriented German spaCy model is now integrated on the NLP branch; no lexical database or grammar checker is integrated yet.
- Existing answer checking is basic exact text comparison, not semantic evaluation.
- No measured NLP quality benchmark or CEFR validation pipeline.

## 3. Target architecture

```text
Flutter client
  | Supabase access token over HTTPS
  v
NLP API gateway / FastAPI
  |-- JWT verification against trusted Supabase project configuration
  |-- authorization, quotas, input limits and request validation
  |-- request correlation, metrics and safe error handling
  |
  |-- Sentence analysis adapter
  |     `-- spaCy `de_core_news_sm` 3.8.0 (initial model; CPU-oriented)
  |-- Grammar adapter
  |     `-- LanguageTool (candidate)
  |-- Vocabulary adapter
  |     `-- OpenThesaurus / approved lexical datasets (candidates)
  |-- Semantic evaluation adapter
  |     `-- benchmarked German-capable sentence embedding model
  |-- Generation and tutor adapter
  |     `-- optional external LLM provider, isolated behind an interface
  `-- Speech adapter (later phase)
        `-- selected ASR / TTS provider

Supabase
  |-- Auth: identity and JWT issuer
  |-- PostgreSQL: learner-owned durable records, RLS
  `-- optional RPCs for narrowly scoped, atomic writes
```

### Architecture rules

1. The Flutter client never contains service-role keys, model-provider keys or privileged NLP credentials.
2. The API validates the Supabase JWT signature, issuer, audience and expiry using trusted project configuration; it does not trust a user ID supplied in the request body.
3. Every learner-owned read/write is authorised for the authenticated subject. Database access must respect RLS or use narrowly scoped server-side operations with explicit subject checks.
4. NLP engines are adapters behind stable internal interfaces so models can be replaced without changing Flutter contracts.
5. User-facing responses are structured, versioned JSON with stable error codes.
6. The authored curriculum and reviewed answer keys remain the educational source of truth. Model output is advisory until validated.
7. Semantic similarity must never be treated as proof of grammatical correctness.
8. Raw writing and conversation text is not retained by default. Any persistence requires documented purpose, consent/notice, access controls and retention/deletion rules.
9. Offline on-device processing is the selected product direction. Core analysis must not require an API, hosting account or payment card; remote processing is optional and must never block offline learning.
10. Do not deploy a paid service as part of the current plan. Revisit hosting only after the user explicitly approves a zero-cost or funded deployment and the privacy/security gates are met.

## 4. Candidate technology and resource register

| Capability | Candidate | Intended use | Gate before adoption |
|---|---|---|---|
| Core linguistic processing | spaCy + German pipeline | tokenization, POS, lemma, morphology, dependency parse | model licence, supported Python version, accuracy benchmark, memory/latency |
| Grammar feedback | LanguageTool | spelling, punctuation and grammar suggestions | server deployment terms, version/licence, German rule quality, privacy and capacity |
| Lexical relations | OpenThesaurus | synonyms and related terms | dataset licence, attribution, redistribution and API/download terms |
| Lexical semantics | GermaNet / Open German WordNet | semantic relations and word senses | exact dataset licence, access terms and redistribution permissions |
| Semantic similarity | Sentence Transformers + selected German-capable model | candidate answer similarity and semantic retrieval | model card, licence, benchmark, inference cost and bias/false-positive tests |
| Corpora | Leipzig / other German corpora | frequency and contextual research | corpus-specific terms, source provenance, redistribution and learner suitability |
| Tutor generation | LLM provider abstraction | explanations and conversation role-play | provider terms, data handling, cost, safety and output validation |
| Speech | selected ASR/TTS provider | transcription, audio and pronunciation features | German support, privacy, latency, licence and cost |

No resource should be bundled merely because it appears in the German-NLP list. The list is a discovery index, not a blanket licence grant. Maintain a checked-in licence register with source URL, exact version/revision, licence text, attribution, redistribution/commercial-use status, review date and reviewer before adding each resource.

## 5. API contract principles

Use a version prefix such as `/api/v1`. All student endpoints require HTTPS and a valid Supabase user access token.

Common request headers:

- `Authorization: Bearer <supabase_access_token>`
- `Content-Type: application/json`
- `X-Request-Id: <client-generated-uuid>` (optional; server generates one if absent)

Common response envelope:

```json
{
  "api_version": "v1",
  "request_id": "uuid",
  "status": "ok",
  "data": {},
  "warnings": []
}
```

Common error envelope:

```json
{
  "api_version": "v1",
  "request_id": "uuid",
  "status": "error",
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The submitted text is too long."
  }
}
```

Initial endpoint proposals:

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/health` | GET | liveness/readiness; no learner data |
| `/api/v1/analyze/sentence` | POST | tokens, lemmas, POS, morphology and syntax |
| `/api/v1/grammar/check` | POST | spelling and grammar matches with offsets |
| `/api/v1/vocabulary/lookup` | POST | word forms, article, plural, meaning and relations |
| `/api/v1/evaluate/answer` | POST | evaluate against exercise rubric and acceptable answers |
| `/api/v1/exercises/generate` | POST | generate a constrained draft exercise |
| `/api/v1/writing/feedback` | POST | structured feedback on a learner text |
| `/api/v1/tutor/message` | POST | one turn in a guided tutor conversation |

Request and response schemas must be defined in Pydantic and exported as OpenAPI. Include explicit limits for text length, batch size, response size, timeouts and per-user quotas. Do not expose arbitrary model parameters or unrestricted prompt fields to clients.

### Sentence analysis response fields

- Original sentence.
- Token text and character offsets.
- Lemma and part-of-speech tag.
- Morphological features when available.
- Dependency relation and head token when available.
- Model/pipeline identifier.
- Warnings for ambiguous or unsupported analysis.

### Grammar feedback response fields

- Rule identifier and category.
- Character range.
- Original fragment.
- Suggested replacement(s).
- Short learner-friendly explanation.
- Severity and confidence where supported.
- Explicit note when a suggestion is stylistic rather than a definite error.

### Answer evaluation response fields

- Outcome: `correct`, `incorrect` or `needs_review`.
- Evaluation method: exact, normalized, rule-based or semantic.
- Matched accepted answer / rubric criterion.
- Explanation.
- Confidence and threshold metadata.
- Grammar assessment kept separate from semantic equivalence.

## 6. CEFR and educational data standards

CEFR levels are not reliably inferred from raw corpus frequency alone. Vocabulary and generated exercises require reviewed level metadata.

Proposed vocabulary fields:

- stable ID and canonical lemma;
- language and part of speech;
- noun gender, plural and inflection information where applicable;
- English gloss and usage notes;
- CEFR level plus source/confidence/reviewer;
- synonyms, antonyms, collocations and word-family relations;
- example sentences with provenance and review status;
- register, region and context labels.

Proposed grammar-rule fields:

- stable rule ID and title;
- CEFR level and prerequisite rules;
- explanation and form/pattern;
- positive and negative examples;
- exceptions and common learner errors;
- exercise templates/rubrics;
- source and editorial review status.

All examples shown to learners must be grammatically checked and appropriate to their level. Preserve umlauts, ß, capitalization and punctuation. Handle separable verbs, compounds, contractions and ambiguous word forms explicitly.

## 7. Data persistence and privacy

Potential tables, introduced only when their semantics are approved:

- `vocabulary_entries`
- `word_relations`
- `grammar_rules`
- `example_sentences`
- `exercise_bank`
- `exercise_attempts`
- `writing_submissions`
- `nlp_analysis_cache`
- `learner_mastery`
- `conversation_sessions`

Do not create all tables at once. First decide which data is static reviewed content, which is transient analysis, and which is learner-owned progress.

Security requirements:

- RLS enabled on learner-owned tables.
- Policies bind records to `auth.uid()`.
- Service credentials are server-only and stored in the deployment secret manager.
- No public write policies for assessment or mastery records.
- Validate ownership and exercise IDs server-side.
- Avoid storing raw submitted text in logs.
- Define deletion and retention behaviour for writing and tutor history.
- Use request quotas and abuse controls.
- Keep cache keys tenant/user-safe; do not return another learner's private result.

## 8. Delivery phases and acceptance criteria

### Phase 0 — Foundation and compatibility

Work:
- Reconcile current `main` and the open A1 curriculum PR.
- Record the curriculum JSON contract and stable exercise IDs.
- Define CEFR metadata and editorial review workflow.
- Create a resource/licence register.
- Draft OpenAPI request/response schemas and error codes.
- Select benchmark sentences and learner-error examples with lawful provenance.
- Decide privacy, retention, hosting region and expected traffic assumptions.

Acceptance:
- Architecture decision record approved.
- API contract reviewed before client integration.
- Every candidate resource has a licence-review status.
- Benchmark set has expected outputs and review notes.
- No production code or schema changes are required to complete this phase.

### Phase 1 — Service infrastructure

Status on the integration branch: FastAPI, Docker, Supabase JWKS JWT verification, protected identity endpoint, security-focused token tests, and dedicated CI are implemented. Real project-issued JWT/JWKS compatibility remains a pre-deployment verification gate.

Work:
- Create a separate Python service directory or repository (decision recorded before implementation).
- Add FastAPI, Pydantic settings, structured logging and health endpoints.
- Add Docker build and local development instructions.
- Implement Supabase JWT verification and authorization tests.
- Add request IDs, rate limiting, input limits, timeouts and safe error mapping.
- Add CI for lint, type checks, unit tests and container build.
- Deploy a non-production service with no learner-data persistence.

Acceptance:
- Valid token accepted; missing, expired, malformed and wrong-project tokens rejected.
- No service secrets in client code or Git.
- Health checks, logs and metrics work.
- CI builds the container reproducibly.

### Phase 2 — Linguistic engine

Status on the integration branch: the first sentence-analysis slice is implemented with spaCy 3.8.18 and the matching `de_core_news_sm` 3.8.0 pipeline. The authenticated `POST /api/v1/analyze/sentence` endpoint returns sentence spans, token offsets, lemmas, POS/tag labels, morphology, dependency heads and named entities. Text is limited to 2,000 characters and is not persisted.

Work remaining:
- Add broader German-specific golden tests and evaluate model quality on learner sentences, not only news-domain text.
- Add response warnings and explicit model metadata/versioning.
- Benchmark latency, memory and cold-start behaviour on the intended hosting tier.
- Review upstream model and training-source notices before commercial redistribution.

Acceptance:
- API schema stable and documented.
- Benchmarks report per-task accuracy; do not claim unmeasured accuracy.
- Latency and memory measured on target hosting.
- Ambiguous and unsupported cases return warnings, not fabricated certainty.
- Analysis endpoint is authenticated, bounded, stateless and covered by regression tests.

### Phase 3 — Vocabulary intelligence

Work:
- Select a licence-approved dictionary/lexical source.
- Build an import pipeline with provenance and deduplication.
- Add word relations, inflections and contextual examples.
- Add CEFR labels only from reviewed sources or editorial assessment.

Acceptance:
- Every imported entry records source and licence provenance.
- Noun gender/plural and verb forms are tested.
- Synonym relations preserve context/register notes.
- No unreviewed corpus text is presented as authored teaching content.

### Phase 4 — Grammar and writing feedback

Work:
- Integrate LanguageTool behind an adapter.
- Normalise match offsets and rule metadata.
- Add learner-friendly explanations mapped to curriculum concepts.
- Distinguish definite errors from optional style suggestions.

Acceptance:
- False-positive and false-negative evaluation documented.
- German cases, verb position, adjective endings, capitalization and punctuation included in tests.
- Suggestions never silently rewrite a learner submission.

### Phase 5 — Semantic answer evaluation

Work:
- Benchmark German-capable embedding candidates.
- Combine exact matching, normalization, rule-based rubrics and semantic similarity.
- Add confidence thresholds and `needs_review` outcomes.
- Keep meaning similarity separate from grammar correctness.

Acceptance:
- Evaluation dataset includes paraphrases, near-misses, negation, tense changes and grammatical errors.
- False acceptance rate is measured and constrained.
- Low-confidence cases are not marked correct automatically.
- Exercise-specific accepted answers remain authoritative.

### Phase 6 — Exercise intelligence

Work:
- Generate draft tasks constrained by CEFR, target grammar and vocabulary.
- Validate answer keys and distractors.
- Reject ambiguous, duplicate, unnatural or level-inappropriate tasks.
- Keep generated content separate from published curriculum until reviewed.

Acceptance:
- Every published exercise has a stable ID, target skill, answer key and explanation.
- Automated checks and human review pass.
- Generated content cannot overwrite authored curriculum.

### Phase 7 — AI tutor

Work:
- Add a provider-neutral LLM adapter.
- Provide curriculum-grounded explanations and role-play.
- Use structured outputs and moderation/guardrails.
- Add conversation controls and retention policy.

Acceptance:
- Provider credentials remain server-side.
- Tutor does not invent grammar rules or claim uncertain output as fact.
- Student data sent to a provider is minimised and disclosed.
- Cost and per-user quotas are enforced.

### Phase 8 — Speech

Work:
- Select German ASR and TTS candidates.
- Add transcription, listening and pronunciation workflows.
- Evaluate dialect/noise limitations and accessibility.

Acceptance:
- German-specific quality and latency benchmarks documented.
- Recording consent, retention and deletion controls implemented.
- Pronunciation scores are presented as estimates, not definitive judgments.

### Phase 9 — Flutter integration

Work:
- Add a typed NLP API client and repository layer.
- Add sentence analyzer, vocabulary, writing and exercise feedback screens.
- Add loading, retry, timeout, empty and service-unavailable states.
- Keep existing auth, navigation and lesson flows stable.

Acceptance:
- No secrets in Flutter.
- Requests attach current Supabase access tokens safely.
- Widget and repository tests cover success and failure paths.
- Existing curriculum and authentication regression tests pass.

### Phase 10 — Production hardening

Work:
- Security review and dependency scanning.
- Load, latency and cost testing.
- CEFR and educational quality review.
- Monitoring, alerting, backups and incident runbooks.
- Gradual rollout with feature flags.

Acceptance:
- All security tests pass.
- Benchmarks and known limitations published.
- Rollback procedure tested.
- Production release approved after Android/Web regression checks.

## 9. Testing strategy

Test layers:

1. Unit tests for each NLP adapter and text normalizer.
2. Contract tests against OpenAPI schemas.
3. Golden linguistic tests for German grammar phenomena.
4. Evaluation tests for answer equivalence and false acceptance.
5. CEFR review tests for vocabulary and generated tasks.
6. Security tests for JWT, authorization, RLS, rate limits and input abuse.
7. Integration tests for Supabase and service interactions.
8. Flutter repository/widget regression tests.
9. Load and resilience tests for model cold starts, timeouts and provider outages.

Benchmark results must include dataset provenance, sample size, metrics, model/version, thresholds and known limitations.

## 10. Operational and deployment considerations

- Prefer a Mumbai or nearby deployment region if available and suitable.
- Use a managed container runtime initially; compare cost and model memory before selecting a provider.
- Load models once per worker and measure cold-start behaviour.
- Keep model downloads pinned and reproducible.
- Separate liveness from readiness checks.
- Use bounded concurrency for memory-heavy models.
- Apply timeouts and circuit breakers to external grammar/LLM providers.
- Record model and ruleset versions with analysis metadata.
- Establish budgets and quotas before enabling LLM or speech endpoints.

## 11. Current delivery sequence (offline-first)

The local Dart engine is integrated into main through PRs #11 and #12. The separate FastAPI/spaCy service and LanguageTool adapter are optional research/integration components; they are not deployed, are not called by the Flutter app and are not required for the learner experience. The user has selected a complete offline scope and a zero monthly hosting budget, so the immediate roadmap is client-side and must not introduce a hosted dependency.

1. Reconcile and validate the A1 curriculum in PR #8 against the current main branch; resolve branch conflicts and run full Flutter CI before merging.
2. Build a reviewed A1 golden-sentence corpus covering correct sentences, common learner errors, ambiguity and counterexamples.
3. Expand the local rules in small tested slices: cases/prepositions, modal verbs, separable verbs, adjective endings, subordinate clauses and word order. Add README and this architecture documentation in every implementation PR.
4. Improve the local lexicon using licence-reviewed data and explicit provenance; keep unknown words conservative.
5. Connect curriculum exercises to rule IDs and explanations without changing learner answers or progress semantics unexpectedly.
6. Benchmark memory, latency and APK size on a representative Android device before considering ONNX. Keep Dart rules as the guaranteed fallback.
7. Keep PR #10 (LanguageTool adapter) draft/deferred. Do not deploy or enable it unless hosting, privacy, licence and operating-cost requirements are explicitly resolved.
8. Consider semantic answer evaluation, tutor and speech only after offline grammar/vocabulary quality is measured and the user approves the added scope.

## 12. Explicit non-goals for the first release

- Rewriting the Flutter application.
- Moving Supabase authentication to Python.
- Exposing service-role credentials to the client.
- Automatically trusting LLM-generated grammar or curriculum.
- Marking semantic similarity as grammatical correctness.
- Importing every resource in the German-NLP catalogue.
- Deploying unreviewed datasets or models.
- Storing all raw learner text indefinitely.
- Claiming CEFR accuracy without a validated benchmark.
