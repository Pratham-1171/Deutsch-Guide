from typing import Any

from fastapi import Depends, FastAPI

from app.config import get_settings
from app.security import get_current_user

settings = get_settings()
app = FastAPI(
    title="Deutsch-Guide German NLP API",
    version="0.1.0",
    description="Authenticated online German-language processing service.",
)


@app.get("/health", tags=["operations"])
def health() -> dict[str, str]:
    """Liveness endpoint. Does not expose configuration or learner data."""
    return {"status": "ok", "service": settings.service_name}


@app.get("/api/v1/me", tags=["security"])
def current_identity(claims: dict[str, Any] = Depends(get_current_user)) -> dict[str, str]:
    """Authentication smoke-test endpoint; returns only the verified subject."""
    return {"subject": claims["sub"], "status": "authenticated"}
