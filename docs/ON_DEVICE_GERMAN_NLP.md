# On-device German NLP architecture

## Product direction

Deutsch-Guide uses an offline-first, on-device architecture for German learning. Supabase remains responsible for identity and progress synchronisation; German text analysis must not require a network connection.

## Current implementation slice

The first client-side engine is a deterministic Dart rules engine at
`lib/features/nlp/domain/german_nlp_engine.dart`. It provides:

- local tokenisation with character offsets;
- separate tokenizer, lexicon, grammar-rule and rule-registry modules;
- explicit A1 rule metadata (stable ID, level, topic and severity);
- selected present-tense agreement for `sein`, `haben`, `lernen`, `wohnen`,
  `kommen`, `machen`, `gehen` and `sprechen`;
- article-form compatibility across supported singular cases, without
  guessing a case-specific replacement when context is insufficient;
- sentence/noun capitalisation and one deliberately narrow main-clause
  word-order pattern;
- stable rule IDs and learner-facing explanations;
- no network calls and no learner-text persistence.

The Grammar route exposes this engine through an offline checker screen. PR #11 introduced the first implementation; PR #12 was merged into `main` as squash commit `e1ba8a9a22a515a681a4561ed6ebe87c1e8c6976`. The merged refactor separates models, tokenizer, lexicon, grammar rules and rule metadata. It adds selected present-tense agreement checks for `sein`, `haben`, `lernen`, `wohnen`, `kommen`, `machen`, `gehen` and `sprechen`, preserves the singular/plural ambiguity of lowercase `sie`, and checks article-form compatibility across supported singular cases without guessing a case-specific replacement. Regression tests cover these behaviours. GitHub Actions run [#46123893794](https://github.com/Pratham-1171/Deutsch-Guide/actions/runs/46123893794) passed formatting, analysis, tests, Android debug APK build/upload and Web build on the PR head. A post-merge workflow is queued separately. Passing CI validates the code and tests, not linguistic completeness or accuracy.

This refactored A1 slice is still a foundation, not complete German NLP coverage. The lexicon is small, rules only inspect narrow local patterns, and plural/article declension, verb placement in complex clauses and many valid sentence structures are not evaluated. A missing finding does
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


## Curriculum integration status

The expanded A1 curriculum was merged in PR #13 as squash commit `98549c26f8ccac583d7bf2ee1cfd39da4bcfbcf7`. It adds ten units, twenty lessons and sixty practice activities in the bundled versioned JSON asset, with regression tests for content completeness and answer-key integrity. The next integration step is to connect reviewed curriculum exercises to stable NLP rule IDs and learner-friendly explanations without changing authored answer keys or uploading learner text. This integration should be implemented incrementally with tests for each supported rule-to-exercise mapping.


## A1 curriculum-aware feedback

The lesson player now uses optional `grammarRuleIds` metadata on curriculum exercises to select relevant findings from the local Dart engine when a learner submits an incorrect German response. The first reviewed mappings cover three full-sentence A1 responses and the existing `DE-VERB-001` present-tense agreement rule. Feedback is advisory and appears separately from the authored answer explanation. It never changes answer keys, marks an answer correct, applies an automatic correction or sends learner text over the network. If no mapped finding is detected, the UI explicitly explains that the current rules have limited coverage. Tests verify that curriculum rule IDs exist in the rule registry and that a mapped agreement error produces the expected suggestion.

Mappings must remain narrow and human-reviewed. Add a mapping only when the response is German text that the selected rule can meaningfully inspect; do not attach every rule to every exercise. Unsupported grammar topics should continue to rely on authored answer keys and explanations until a dedicated rule and regression corpus exist.
