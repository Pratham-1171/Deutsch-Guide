from datetime import UTC, datetime, timedelta
from types import SimpleNamespace

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from fastapi.testclient import TestClient

from app.config import Settings
from app.main import app
from app.security import get_current_user, verify_supabase_token

client = TestClient(app)


def test_health_is_public_and_minimal() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert "supabase_url" not in response.json()


def test_identity_requires_bearer_token() -> None:
    response = client.get("/api/v1/me")
    assert response.status_code == 401


def test_identity_returns_verified_subject_only() -> None:
    app.dependency_overrides[get_current_user] = lambda: {
        "sub": "user-123",
        "email": "private@example.test",
        "role": "authenticated",
    }
    try:
        response = client.get("/api/v1/me")
        assert response.status_code == 200
        assert response.json() == {
            "subject": "user-123",
            "status": "authenticated",
        }
    finally:
        app.dependency_overrides.clear()


@pytest.fixture
def signing_keys():
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    return private_key, private_key.public_key()


@pytest.fixture
def supabase_settings() -> Settings:
    return Settings(supabase_url="https://example.supabase.co")


def _token(private_key, **claim_overrides) -> str:
    now = datetime.now(UTC)
    claims = {
        "sub": "learner-123",
        "iss": "https://example.supabase.co/auth/v1",
        "aud": "authenticated",
        "iat": now,
        "exp": now + timedelta(minutes=5),
    }
    claims.update(claim_overrides)
    return jwt.encode(claims, private_key, algorithm="RS256", headers={"kid": "test-key"})


def test_supabase_token_verification_accepts_valid_rs256_token(
    monkeypatch, signing_keys, supabase_settings
) -> None:
    private_key, public_key = signing_keys

    class FakeJwksClient:
        def get_signing_key_from_jwt(self, token):
            return SimpleNamespace(key=public_key)

    monkeypatch.setattr("app.security._jwks_client", lambda url: FakeJwksClient())

    claims = verify_supabase_token(_token(private_key), supabase_settings)

    assert claims["sub"] == "learner-123"
    assert claims["aud"] == "authenticated"


@pytest.mark.parametrize(
    "overrides",
    [
        {"iss": "https://attacker.example/auth/v1"},
        {"aud": "admin"},
        {"exp": datetime.now(UTC) - timedelta(minutes=1)},
        {"sub": ""},
    ],
)
def test_supabase_token_verification_rejects_invalid_claims(
    monkeypatch, signing_keys, supabase_settings, overrides
) -> None:
    private_key, public_key = signing_keys

    class FakeJwksClient:
        def get_signing_key_from_jwt(self, token):
            return SimpleNamespace(key=public_key)

    monkeypatch.setattr("app.security._jwks_client", lambda url: FakeJwksClient())

    with pytest.raises(jwt.InvalidTokenError):
        verify_supabase_token(_token(private_key, **overrides), supabase_settings)


def test_supabase_token_verification_rejects_unapproved_algorithm(
    monkeypatch, signing_keys, supabase_settings
) -> None:
    private_key, public_key = signing_keys

    class FakeJwksClient:
        def get_signing_key_from_jwt(self, token):
            return SimpleNamespace(key=public_key)

    monkeypatch.setattr("app.security._jwks_client", lambda url: FakeJwksClient())
    token = jwt.encode(
        {
            "sub": "learner-123",
            "iss": supabase_settings.jwt_issuer,
            "aud": "authenticated",
            "iat": datetime.now(UTC),
            "exp": datetime.now(UTC) + timedelta(minutes=5),
        },
        "not-a-rsa-key",
        algorithm="HS256",
    )

    with pytest.raises(jwt.InvalidTokenError):
        verify_supabase_token(token, supabase_settings)


def test_supabase_token_verification_requires_configuration() -> None:
    with pytest.raises(RuntimeError, match="not configured"):
        verify_supabase_token("unused", Settings())

def test_sentence_analysis_requires_bearer_token() -> None:
    response = client.post(
        "/api/v1/analyze/sentence",
        json={"text": "Ich lerne Deutsch."},
    )
    assert response.status_code == 401


def test_sentence_analysis_rejects_blank_text() -> None:
    response = client.post(
        "/api/v1/analyze/sentence",
        json={"text": "   "},
    )
    assert response.status_code == 422


def test_german_pipeline_returns_lemmas_and_morphology() -> None:
    from app.nlp import analyze_german_text

    result = analyze_german_text("Ich lerne Deutsch.")

    assert result["language"] == "de"
    assert result["model"] == "de_core_news_sm"
    assert result["model_version"] == "3.8.0"
    assert [token["text"] for token in result["tokens"]] == [
        "Ich",
        "lerne",
        "Deutsch",
        ".",
    ]
    assert result["tokens"][1]["lemma"]
    assert isinstance(result["tokens"][1]["morphology"], dict)
    assert len(result["sentences"]) == 1
