from fastapi.testclient import TestClient

from app.main import app
from app.security import get_current_user

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
