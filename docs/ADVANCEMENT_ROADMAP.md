# Deutsch-Guide — Master Advancement Roadmap

**Status date:** 28 November 2026  
**Audit baseline:** main commit 06490416671cde7c5d7b777ea7e1948b3ab6c7f8  
**Source:** Owner-approved Detailed Advancement Plan supplied on 28 November 2026.

This document is the canonical sequence for future product and engineering work. The repository snapshot below is a dated audit baseline, not a claim that planned features are already implemented. Update this roadmap, the README, and the relevant phase document in the same PR whenever a substantive implementation changes project status.

## Current execution notes

- PR #15 is merged as 06490416671cde7c5d7b777ea7e1948b3ab6c7f8.
- PR #16 merged as a1a56b09b0c0d5e41f429cc67136a29b7154e535. It adds the initial bundled A1 noun catalog, typed repository, validation and tests. Phase 9 must build on this vocabulary foundation as the single lexical source of truth; do not create a competing duplicate catalog.
- The verified baseline has no persistent lesson progress, no dictionary/SRS product flow, and no completed listening workflow. These remain roadmap work, not shipped features.

## Product and engineering constraints

1. Learner-facing UI and explanations remain **English only**; German is the target language. Do not add translated UI or another interface language.
2. Learning and local German NLP remain **offline-first**. Network loss must not block lessons, local analysis or review.
3. Authored curriculum and answer keys remain the educational source of truth. NLP hints are supplemental and must never silently override answer keys.
4. Keep provider secrets out of Flutter. Apply RLS, least-privilege grants, tests and privacy controls to all learner data.
5. Adopt models, datasets, audio and external lexical sources only after licence and technical review.
6. Ship small, reviewable PRs with regression tests. README and relevant phase documentation must be updated in the same PR.

---

## Track A — Product advancement

### Phase 7 — Persistent progress and the learning loop

**Priority:** first product phase after the B1 repository quick wins.

Build a local-first progress feature that works signed out and offline. Add a progress domain for lesson progress and exercise attempts, local persistence keyed by stable curriculum IDs, a remote sync repository and Riverpod providers. Start with SharedPreferences; move to Drift/SQLite in Phase 9 when indexed review queries justify it.

Add Supabase tables for lesson progress and append-only exercise attempts. Follow the hardened learner-profile migration pattern: user-scoped RLS, explicit revoke/grant permissions, an updated-at trigger, and no update/delete permission for attempt history. Write locally first, sync on resume or sign-in, use updated-at last-write-wins for lesson progress, and make retries idempotent. A sync failure must never block learning.

Replace the static dashboard summary with continue-learning, per-unit completion and answered/accuracy indicators. Merge signed-out local progress into the authenticated account once, idempotently.

**Acceptance gates**
- Complete a lesson with the network disabled, close/reopen the app, and retain completion.
- Sign in on a second device and verify progress appears.
- Add SQL security tests proving one user cannot read or mutate another user's rows.
- Unit-test merge/conflict behavior and widget-test empty, in-progress and error dashboard states.

### Phase 8 — Complete A1 grammar and richer exercise types

Execute the existing A1 grammar gap audit without restructuring the ten thematic units. Extend the curriculum schema to version 2 while preserving version 1 loading. Add reusable support for multiple blanks, word-order tiles, matching and transformation exercises.

Author eight grammar practice sets in the audit's priority order:
1. Noun gender, plural patterns and definite/indefinite articles.
2. Nominative subjects and the full personal-pronoun table.
3. Statements, W-questions, yes/no questions and verb position.
4. nicht versus kein.
5. Accusative articles and object pronouns.
6. Modal verb conjugation and infinitive-final clauses.
7. Dative introduction and common dative expressions.
8. Perfekt auxiliary selection and common participles.

Each new exercise needs a stable ID, CEFR objective, unambiguous canonical answer and accepted variants, plus an English explanation. Map exercises to NLP rule IDs only after the corresponding rule has been reviewed and merged.

**Acceptance gates**
- Update unit/lesson/exercise regression totals and verify accepted variants.
- Add a content-lint test for unique IDs, valid grammarRuleIds and feedback on every exercise.
- Widget-test rendering and grading for every new exercise type.
- Preserve version 1 curriculum compatibility.

### Phase 9 — Vocabulary, dictionary and spaced repetition

Build one canonical, versioned A1 vocabulary source linked to lesson IDs. Reuse and evolve the PR #16 vocabulary foundation after it merges; normalize or migrate that schema deliberately rather than maintaining parallel lexical catalogs. Generate the NLP lexicon from the canonical vocabulary source in Phase 11.

Add an offline dictionary with prefix/substring search, umlaut-tolerant search, word details, article/plural display, and reviewed present-tense conjugation data. Add a review queue and daily practice. Start with five-box Leitner scheduling because it is simple and testable; consider FSRS only after real attempt data exists. Persist review items locally and sync idempotently with RLS.

**Acceptance gates**
- Test scheduling as a pure function, including lapse, promotion and timezone boundaries.
- Review works fully offline and sync is idempotent.
- Every entry traces to a lesson and every entry renders in data-driven tests.
- External dictionaries/lexical datasets require licence review.

### Phase 10 — Audio and listening

Use device text-to-speech with a German de-DE voice for phrase chunks, exercise prompts and dictionary entries. Verify platform voice availability and show a graceful fallback when a German voice is absent. Add listening-choice and dictation exercise types, with one or two listening activities per existing unit. Keep speaking/pronunciation work behind the existing feature flag for a later phase. Bundled or pre-rendered audio is a later, licence-gated enhancement; do not use scraped audio.

**Acceptance gates**
- Mock TTS in listening exercise tests.
- Device TTS works without a network request.
- Audio controls have accessible labels and adequate tap targets.

### Phase 11 — Offline NLP depth (engine v0.3–v0.5)

Grow the deterministic Dart checker alongside Phase 8, retaining the precision-first rule: no finding does not certify correctness. Generate the lexicon from canonical vocabulary data. Add one rule family per PR, with registry metadata and a golden corpus:
- DE-NEG-001: selected nicht/kein misuse.
- DE-ACC-001: accusative article forms after a closed set of known transitive verbs.
- DE-V2-001: selected verb-second violations.
- DE-SEP-001: separable-prefix placement.
- DE-DAT-001: dative after a closed preposition list.
- DE-PERF-001: haben/sein selection and reviewed participle forms.

Build a corpus with at least ten correct and ten incorrect examples per rule. Track precision and recall and enforce a false-positive budget in CI. Expand curriculum-to-rule mappings only when a rule is available and reviewed. Decide PR #10 (LanguageTool) by either completing it as an optional server-side adapter or closing it with a documented rationale. Pursue ONNX only after licence, operator-compatibility, device-benchmark and corpus-quality gates pass.

### Phase 12 — A2 curriculum and scalable content authoring

Add a curriculum manifest describing levels, assets and content versions. Author A2 to the same curriculum contract, with ten units that mirror the A1 structure. Cover the approved A2 scope: subordinate clauses/verb-final position, adjective declension, reflexive verbs, comparisons, Präteritum of haben/sein/modals, introductory genitive/passive and relative clauses.

Create a formal JSON Schema and CI validation. Document the authoring contract, stable IDs, CEFR tagging and answer-ambiguity checklist in docs/AUTHORING.md. A Dart validation CLI may supplement the schema check. Keep level availability honest in the UI; do not advertise unbuilt levels as active.

### Phase 13 — Optional online NLP tier

Only after the offline product is solid. If enabled, deploy the existing FastAPI service with rate limits, request-size caps, structured logs and health monitoring. The Flutter remote adapter must remain optional, authenticated, bounded by strict timeouts and unable to block offline features.

Consider semantic grading only for explicitly designated free-text tasks, with curated equivalent/wrong-but-similar pairs, a documented false-accept budget and authored answer keys retaining authority. An AI tutor must be default-off, use server-side provider keys, CEFR-constrained structured outputs, per-user quotas with RLS and an explicit retention/deletion policy. Add observability with PII scrubbing; learner writing must not appear in crash reports.

---

## Track B — Engineering and repository maturity

This workstream runs alongside the product phases, respecting the sequence below.

### B1 — Quick wins (first)

- Create a v0.1.0 release using the existing CI artifacts; include the debug APK and Web build and start a Keep-a-Changelog file. Do not imply a signed production release if signing is not configured.
- Prune only branches proven to belong to merged PRs; decide the fate of PR #10 at Phase 11.
- Polish README with CI/license/release status, real screenshots when available, and an Implemented / In progress / Planned feature table. Keep long technical explanations in docs.
- Add CONTRIBUTING.md, SECURITY.md and issue/PR templates based on current project practices.
- Improve CI hygiene: concurrency cancellation, centralised public build variables, and correct debug-build environment naming.
- Add Dependabot for GitHub Actions, Python dependencies and pub dependencies. Manage Flutter SDK upgrades deliberately.
- Set teacherWorkspace off until the teacher feature actually exists, after verifying current flag behavior and tests.

### B2 — Testing depth

- Add coverage reporting and target at least 80% for domain layers, not a vanity global percentage.
- Add golden tests for lesson-player states and grammar findings.
- Add an integration journey covering registration, onboarding, lesson use, answering, completion and persistence. Prefer Web CI for routine coverage; run Android emulator tests on a scheduled cadence.
- Run Supabase migrations and SQL security tests in CI, extending the suite for each new learner table.
- Add the NLP corpus precision/recall harness in Phase 11.

### B3 — Release engineering

Add a tag-triggered release workflow for signed AAB/APK, Web bundle and Windows package. Store signing material only in GitHub Secrets. Attach build artifacts and generated release notes to GitHub Releases. Evaluate GitHub Pages or Cloudflare Pages for the Web demo. Version app releases and learning content independently.

### B4 — Architecture hardening

Keep the feature-first layout and gradually standardize domain/data/presentation separation. Evaluate code generation when curriculum schema v2 expands model complexity. Introduce typed repository failures, consistent loading/error states and isolate-friendly lazy asset parsing when justified by data size. Record durable architecture decisions in docs/decisions.

### B5 — Security and supply chain

Add secret scanning, pin third-party Actions to commit SHAs, keep workflow permissions minimal, run Supabase database linting and document backup/PITR readiness. Verify the email-confirmation and recovery flows end to end before real-user rollout.

---

## Master sequence

| Order | Work | Dependency/reason |
|---:|---|---|
| 0 | B1 quick wins and v0.1.0 release | Repository credibility and housekeeping |
| 1 | Phase 7: persistent progress | Foundation for retention and learner analytics |
| 2 | B2: coverage and database tests in CI | Safety net before larger schema/content changes |
| 3 | Phase 8: A1 grammar and exercise types | Fills the audited A1 learning gaps |
| 4 | Phase 9: vocabulary, dictionary and SRS | Builds the daily retention loop |
| 5 | Phase 10: TTS and listening | Adds a second learning skill at low infrastructure cost |
| 6 | Phase 11: offline NLP rules and corpus | Measurable quality; resolves PR #10 |
| 7 | B3: release pipeline and live Web demo | Ships verified builds to users |
| 8 | Phase 12: A2 and content pipeline | Scales the curriculum |
| 9 | Phase 13: optional online NLP and AI tutor | Only after offline readiness and all safety gates |

The three highest-leverage product phases remain **7 → 8 → 9**: persistence, systematic A1 grammar, then vocabulary/SRS.

## Definition of done for every phase

- Scoped PR with acceptance criteria and a phase document.
- Regression tests for new logic/content; RLS tests for each learner table.
- CI green for formatting, analysis, tests and applicable builds.
- README and relevant roadmap/phase docs updated in the same PR.
- Offline behavior verified where applicable, no client secrets, and licences documented.

## Risks to manage

1. Content authoring and answer-key quality are the bottleneck; build content lint/schema validation early.
2. Keep NLP precision-first and measure false positives. A wrong correction harms beginner trust more than a missing suggestion.
3. Keep sync simple: last-write-wins progress and append-only attempts; do not introduce CRDT or multi-device merge complexity without need.
4. Keep Phase 13 cost-controlled, quota-limited and default-off.
5. Maintain honest README status so planned functionality is never presented as shipped.
