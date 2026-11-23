# Phase 6 — Complete the A1 Curriculum

## Goal

Turn the initial A1 sample into a coherent, navigable beginner pathway with enough lesson content and practice for learners to work through the main everyday communication situations at CEFR A1.

## Curriculum scope

The bundled German A1 curriculum is authored in `assets/curriculum/v1/a1.json` and remains independent of Flutter widgets and Supabase.

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
- No offline mode or offline synchronisation.
- No progress analytics, streaks, mastery or spaced-repetition persistence.
- No teacher account/dashboard implementation in this phase; teacher/student account work remains a separately scoped phase.
- No A2–C2 curriculum content in this phase.

## Acceptance criteria

- A1 loads from the bundled asset without network access.
- The course catalogue exposes all ten units and twenty lessons.
- Every lesson can be opened by its stable ID and rendered by the same lesson player.
- The learner can complete the three-or-more activities in a lesson and reach the completion screen.
- Tests verify curriculum totals, required lesson content, supported exercise types and answer checking.
- CI passes formatting, static analysis, tests, Android debug build and Web build.
