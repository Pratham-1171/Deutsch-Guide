# Phase 6 — Complete the A1 Curriculum

## Goal

Turn the initial A1 sample into a coherent, navigable beginner pathway with enough lesson content and practice for learners to work through the main everyday communication situations at CEFR A1.

## Curriculum scope

The bundled German A1 curriculum is authored in `assets/curriculum/v1/a1.json` and remains independent of Flutter widgets and Supabase.


## Product language requirement

Keep lesson instructions, prompts and explanations in clear beginner-friendly English, with German as the target language. Do not introduce additional interface languages or translated UI content.

The pathway contains ten units and twenty lessons:

1. Hallo und willkommen — greetings, introductions, formal and informal address
2. Ich und meine Welt — origin, languages, numbers and personal details
3. Familie und Menschen — family, possessives and simple descriptions
4. Mein Alltag — daily routines, separable verbs, clock times and weekdays
5. Essen und Trinken — food, preferences, ordering and basic accusative forms
6. Wohnen und Zuhause — rooms, furniture and location phrases
7. Einkaufen und Kleidung — clothes, colours, prices, quantities and shopping
8. Freizeit und Verabredungen — hobbies, invitations and modal verb können
9. Unterwegs und gesund — transport, directions, weather and basic health phrases
10. Pläne und Erlebnisse — modal verbs wollen/müssen and an introduction to Perfekt

## Lesson content contract

Every lesson contains:
- Stable lesson ID and a clear title.
- Measurable learning objectives.
- German phrase chunks with clear English meanings.
- At least three practice activities.
- Single-choice and typed short-answer items with answer keys and explanatory feedback.

Examples should be natural, beginner-friendly and useful in everyday communication. Exercise answers must be unambiguous. Short-answer matching is case-insensitive and ignores outer whitespace; it does not silently accept arbitrary grammatical variants.

## Engineering work

- Keep the versioned JSON content as the source of truth.
- Preserve the reusable data-driven lesson player.
- Add regression tests for unit, lesson and exercise totals and for minimum lesson completeness.
- Keep lesson completion session-only; no progress persistence is introduced in this phase.
- Preserve existing authentication, learner profile and navigation behaviour.

## Explicit exclusions

- No administrator account or administrator role.
- No dedicated offline-download manager or progress synchronisation is introduced. The bundled JSON curriculum itself remains available locally without a network connection.
- No progress analytics, streaks, mastery or spaced-repetition persistence.
- No teacher account/dashboard implementation in this phase; teacher/student account work remains a separately scoped phase.
- No A2–C2 curriculum content in this phase.

## Acceptance criteria

- A1 loads from the bundled asset without network access; this is bundled-asset availability, not a separate offline-download feature.
- The course catalogue exposes all ten units and twenty lessons.
- Every lesson can be opened by its stable ID and rendered by the same lesson player.
- The learner can complete the three-or-more activities in a lesson and reach the completion screen.
- Tests verify curriculum totals, required lesson content, supported exercise types and answer checking.
- CI passes formatting, static analysis, tests, Android debug build and Web build.


## Reconciliation with current main

This curriculum update was merged on top of `main` after the offline NLP engine and its architecture documentation in PR #12. PR #13 was squash-merged as `98549c26f8ccac583d7bf2ee1cfd39da4bcfbcf7`. The change adds the versioned A1 curriculum asset, curriculum regression tests and this plan. It does not modify the NLP engine, authentication, navigation or progress storage.

Additional regression coverage verifies that every authored canonical short answer and every declared accepted variant is recognised by the existing case-insensitive answer matcher, and that each lesson has exactly three practice items.


## Curriculum-aware NLP feedback follow-up

The first integration slice adds optional `grammarRuleIds` to curriculum exercise data and displays filtered offline NLP hints after an incorrect response on explicitly mapped items. The initial reviewed mappings target three full-sentence responses for the existing present-tense agreement rule. This is supplemental feedback only: authored answer checking remains authoritative and unchanged, and learner text remains on device. Future mappings require a matching registered rule, a reviewed example and regression coverage; unsupported cases must not receive speculative corrections.


## Vocabulary foundation follow-up

The first reusable content slice is a separate versioned A1 noun catalog at `assets/learning_content/v1/a1_vocabulary.json`. It complements, and does not replace, the ten-unit lesson curriculum. Each entry stores a stable ID, lemma, nominative singular article, plural form when applicable, English meaning, topic ID, CEFR level and an original German/English example pair. The Flutter data model validates IDs, article values, level consistency and required fields before content is exposed to features.

The first catalog is intentionally a curated starter set, not a claim that the full 1,000-word reference has been imported. Next slices: expand and QA topic vocabulary; add verb lemmas and conjugation records from the self-authored irregular-verb and `sein` Perfekt references; connect the spoken-pattern and separable-verb banks; then expose search, flashcards and spaced review. The existing lesson asset and answer keys remain authoritative until each integration is reviewed and tested.
