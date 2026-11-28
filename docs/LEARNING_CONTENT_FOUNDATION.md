# Learning Content Foundation

## Product constraints

- English is the learner-facing instruction and explanation language; German is the target language.
- Bundled learning content must work offline. No NLP service, external API or paid hosting is required to read vocabulary.
- Keep the existing lesson curriculum and answer keys intact. Shared content is added as a separate, versioned catalog and linked into lessons in later reviewed slices.
- Content is curated by CEFR level and topic. A source's A1–B1 label does not make every item A1.

## Source-use policy

The project owner confirms that these supplied PDFs are self-authored and may be used freely within Deutsch-Guide:

- 1,000 High-Frequency German Words by Topic
- 100 Spoken German Patterns Workbook (patterns 1–100)
- 100 More Spoken German Patterns Workbook (patterns 101–200)
- A1 Irregular Verbs
- Verben mit SEIN im Perfekt
- German A1–B1 Separable Verbs

Use them as primary project content sources, while retaining editorial validation for CEFR tagging, inflection, naturalness and duplicate handling. Preserve source attribution in this internal document and any future source register.

The *German Visual Dictionary for Dummies* is not self-authored. It may inform topic discovery and visual-learning ideas only; do not copy its protected text, pages or illustrations. Use original or separately licensed visual assets.

## Canonical A1 noun record

The initial JSON catalog uses these fields:

| Field | Purpose |
|---|---|
| `id` | Stable unique content identifier |
| `lemma` | German singular noun, without article |
| `partOfSpeech` | `noun` |
| `level` | CEFR level, initially A1 |
| `article` | Nominative singular `der`, `die` or `das` |
| `plural` | Plural form; null only for mass nouns with no normal learner plural |
| `meaningEn` | Concise English meaning |
| `topicId` | Stable topic key for grouping and filtering |
| `exampleDe` / `exampleEn` | Original, paired example sentence and translation |

Nouns should be learned with their article and plural, not as an isolated spelling. Examples are newly authored for the app and should be short, natural and level-appropriate.

## Asset and code locations

- Source JSON: `assets/learning_content/v1/a1_vocabulary.json`
- Typed model and validation: `lib/features/vocabulary/data/vocabulary_repository.dart`
- Tests: `test/vocabulary_repository_test.dart`
- Existing lesson curriculum: `assets/curriculum/v1/a1.json` (unchanged)

The vocabulary repository is separate from the lesson curriculum repository. It does not add a screen or alter navigation in this first slice.

## Integration stages

1. **A1 noun foundation:** articles, plurals, meanings, topics and original examples; schema validation and offline asset tests.
2. **A1/A2 topic expansion:** fill the remaining high-value word groups, remove duplicates and tag level precisely.
3. **Verb foundation:** canonical infinitives, present-tense forms, irregular stem changes, separability and Perfekt auxiliary/participle records.
4. **Grammar links:** connect vocabulary to article/case rules, verb agreement, word order and separable-verb rules.
5. **Speaking patterns:** add all 200 self-authored frames with CEFR tags, grammar links, vocabulary slots and editorial review; do not blindly assume each frame is A1.
6. **Practice and review:** build deterministic exercises, retrieval practice and later spaced repetition on top of the shared catalog.
7. **A2/B1 expansion:** add higher-level content only after A1 quality and coverage gates pass.

## Editorial quality gates

- Every noun has a reviewed article and plural (or an explicitly justified null plural).
- Every record has one stable ID and one canonical lemma; duplicates are resolved rather than hidden.
- Example sentences use grammar already taught or explicitly explain new grammar.
- English meanings are concise and distinguish common senses when needed.
- Separable/inseparable verb status and Perfekt auxiliary are stored per verb, not inferred from prefix alone.
- Regional and usage notes are preserved where relevant. For example, the supplied *sein* Perfekt reference notes regional variation for `liegen`, `sitzen` and `stehen`; the app should explain standard exam usage separately from regional speech.
- Every content update includes README and relevant phase-plan updates, plus regression tests.
- No Gujarati or additional learner-interface locales are introduced.

## Current implementation status

The initial A1 noun catalog is a curated subset of the self-authored topic vocabulary reference. It is not the full 1,000-word list, and it is not yet surfaced in a learner-facing screen. The next step is to expand and cross-check the catalog before adding verbs and speaking patterns.
