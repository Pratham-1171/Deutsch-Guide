# Deutsch-Guide German NLP API

Initial service foundation for the online German NLP backend.

## Current scope

- FastAPI application and public liveness endpoint.
- Supabase JWT verification through the project's published JWKS.
- Protected identity smoke-test endpoint at `GET /api/v1/me`.
- Docker image definition and isolated Python test/lint dependencies.

No NLP model, grammar engine, database write, learner-text storage or production deployment is included yet.

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

The verifier deliberately uses asymmetric keys published by Supabase. Before deployment, confirm the project is configured with a supported asymmetric signing key and verify issuer/audience values against a real project-issued access token. Do not put the legacy JWT secret, service-role key or any other secret in this repository or the Flutter app.

## Endpoints

- `GET /health`: public liveness check; reveals no configuration.
- `GET /api/v1/me`: protected authentication smoke test; returns only the verified user subject.

This is not yet a complete production API. Add feature endpoints only with reviewed request/response schemas, authorization, quotas, timeouts and tests.
