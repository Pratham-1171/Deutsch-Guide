# On-device German NLP architecture

## Product direction

Deutsch-Guide uses an offline-first, on-device architecture for German learning. Supabase remains responsible for identity and progress synchronisation; German text analysis must not require a network connection.

## Current implementation slice

The first client-side engine is a deterministic Dart rules engine at
`lib/features/nlp/domain/german_nlp_engine.dart`. It provides:

- local tokenisation with character offsets;
- a small, explicitly scoped German lemma/POS lexicon;
- conservative A1–B1 starter checks for sentence/noun capitalisation,
  common `sein`/`haben` agreement, selected noun gender/article pairs,
  and one simple main-clause word-order pattern;
- stable rule IDs and learner-facing explanations;
- no network calls and no learner-text persistence.

The Grammar route exposes this engine through an offline checker screen. The initial CI formatting differences and analyzer lint were corrected. The final CI run for commit `90bcebee` passed Dart formatting, Flutter analysis, unit tests, Android debug APK build and web build (GitHub Actions run [#46116783059](https://github.com/Pratham-1171/Deutsch-Guide/actions/runs/46116783059)). PR #11 was merged into `main` as squash commit `cc76b610`. This validates the build and current tests, not the completeness or linguistic accuracy of the rule set.

PR A (`feat/nlp-rule-engine-a1`) is in progress. It refactors the engine into a facade over dedicated tokenizer, lexicon and grammar-rule modules, adds A1 rule metadata and broadens selected present-tense agreement checks. Article checks now test whether a form is possible for the noun's gender across supported cases; when a mismatch is found, the engine deliberately avoids suggesting a nominative article without knowing the case. Regression tests cover valid masculine, feminine and neuter forms.\n\nThis refactored A1 slice is still a foundation, not complete German NLP coverage. The lexicon is small, rules only inspect narrow local patterns, and plural/article declension, verb placement in complex clauses and many valid sentence structures are not evaluated. A missing finding does
not prove that a sentence is correct. Rules must remain conservative and be
expanded with reviewed examples and regression tests.

## Model inference plan

The Python spaCy pipeline is not a mobile runtime and is not bundled in the APK.
A separate mobile-model adapter should be introduced only after selecting and
benchmarking a redistributable German model converted to ONNX. The adapter must
be optional and lazy-loaded, with the Dart engine remaining a working fallback.

Acceptance gates for the ONNX stage:

1. Confirm model provenance, exact licence and redistribution rights.
2. Export or obtain a compatible ONNX graph and tokenizer assets.
3. Validate Android arm64 runtime compatibility and model operators.
4. Benchmark APK/download size, peak RAM, cold-start time and sentence latency
   on representative low/mid-range Android devices.
5. Compare tokenisation, lemma, POS and morphology against a reviewed German
   A1–B1 test set; document accuracy and known failure modes.
6. Keep model assets versioned and integrity-checked. Downloadable packs must
   be optional and resumable; the base Dart rules remain available offline.
7. Do not claim dependency parsing, named entities or full grammar correction
   until a validated model actually supplies those outputs.

## Data and privacy

- Sentence analysis is local by default.
- Do not upload learner text to Supabase as part of analysis.
- Sync only progress/learning events through existing authenticated flows.
- Any future optional online service must be explicit, separately configured,
  and must not block offline analysis.

## Future layers

- reviewed A1–B1 vocabulary and inflection data;
- richer conjugation, case, adjective-declension and clause-order rules;
- optional ONNX token/POS/morphology model;
- curriculum-linked explanations and exercise-aware feedback;
- model pack manager with version, checksum, download progress and storage
  controls.
