# Deutsch-Guide German NLP API

Initial service foundation for the online German NLP backend.

## Current scope

- FastAPI application and public liveness endpoint.
- Supabase JWT verification through the project's published JWKS.
- Protected identity smoke-test endpoint at `GET /api/v1/me`.
- First German NLP capability: authenticated `POST /api/v1/analyze/sentence`.
- Authenticated German spelling and grammar feedback through a configurable LanguageTool-compatible server at `POST /api/v1/grammar/check`.
- Pinned CPU-oriented spaCy German pipeline (`de_core_news_sm` 3.8.0).
- Sentence spans, tokenization, lemmas, POS/tag labels, morphology, dependency heads and named entities.
- Docker image definition and isolated Python test/lint dependencies.

The analysis and grammar endpoints are stateless from this service's perspective: it does not persist submitted learner text. Grammar text is forwarded to the configured LanguageTool server, so that server's own privacy and retention settings also apply. Do not use the public free LanguageTool endpoint for automated app traffic; its published policy prohibits automated requests. No database write, learner-text storage or production deployment is included yet.

## Local development

Requires Python 3.12.

```bash
cd services/german-nlp
python -m venv .venv
# Activate the virtual environment, then:
pip install -r requirements-dev.txt
uvicorn app.main:app --reload --port 8080
```

Run checks:

```bash
pytest
ruff check app tests
```

## Supabase configuration

Set these environment variables in the service runtime:

- `SUPABASE_URL`: project URL.
- `SUPABASE_JWKS_URL`: optional override; defaults to `{SUPABASE_URL}/auth/v1/.well-known/jwks.json`.
- `SUPABASE_JWT_ISSUER`: optional override; defaults to `{SUPABASE_URL}/auth/v1`.
- `SUPABASE_JWT_AUDIENCE`: defaults to `authenticated`.
- `SUPABASE_JWT_ALGORITHMS`: comma-separated asymmetric signing algorithms supported by the project's published JWKS.
- `LANGUAGETOOL_URL`: base URL of your self-hosted or contracted LanguageTool-compatible server, for example `http://languagetool:8010`. Leave unset to disable grammar checking.
- `LANGUAGETOOL_TIMEOUT_SECONDS`: request timeout in seconds; defaults to `8`.

The verifier deliberately uses asymmetric keys published by Supabase. Before deployment, confirm the project is configured with a supported asymmetric signing key and verify issuer/audience values against a real project-issued access token. Do not put the legacy JWT secret, service-role key or any other secret in this repository or the Flutter app.

## Endpoints

- `GET /health`: public liveness check; reveals no configuration.
- `GET /api/v1/me`: protected authentication smoke test; returns only the verified user subject.
- `POST /api/v1/analyze/sentence`: protected German text analysis. Request body: `{"text":"Ich lerne Deutsch."}`. Text is limited to 2,000 characters. The response includes sentence spans, token annotations, morphology, dependency relations and detected entities.
- `POST /api/v1/grammar/check`: protected German spelling and grammar feedback. Request body: `{"text":"Ich gehen heute zur Schule."}`. Text is limited to 2,000 characters. The response returns LanguageTool matches with character offsets, rule/category metadata, context and up to five replacement suggestions per match. Returns `503` if LanguageTool is not configured or unavailable.

Example request:

```bash
curl -X POST http://localhost:8080/api/v1/analyze/sentence \\
  -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{"text":"Ich lerne heute Deutsch."}'
```

## NLP model and limitations

The service pins spaCy 3.8.18 and the matching `de_core_news_sm` 3.8.0 model. The small pipeline is CPU-oriented and provides tokenization, part-of-speech and morphology labels, lemmatization, dependency parsing, sentence segmentation and named entities. Its model metadata declares MIT; upstream source notices also identify the TIGER corpus (commercially licensed by Explosion) and WikiNER (CC BY 4.0). See `THIRD_PARTY_NOTICES.md`. Do not redistribute the original training corpora.

The spaCy endpoint does **not** claim to detect grammatical errors, assign CEFR levels, or judge whether a sentence is natural or correct. Grammar suggestions come from LanguageTool and should be presented as suggestions, not authoritative grades: validate them against learner-level examples before using them for scoring. The self-hosted LanguageTool server is a separate deployment component; configure it privately and apply its own resource limits, updates and access controls. Do not route automated app traffic to LanguageTool's public free endpoint. This service is not yet a complete production API: add features only with reviewed schemas, authorization, quotas, timeouts and tests.
