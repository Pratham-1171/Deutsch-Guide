from typing import Any

from fastapi import Depends, FastAPI, HTTPException, status

from app.config import get_settings
from app.nlp import analyze_german_text
from app.schemas import SentenceAnalysisRequest, SentenceAnalysisResponse
from app.security import get_current_user

settings = get_settings()
app = FastAPI(
    title="Deutsch-Guide German NLP API",
    version="0.2.0",
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


@app.post(
    "/api/v1/analyze/sentence",
    response_model=SentenceAnalysisResponse,
    tags=["analysis"],
)
def analyze_sentence(
    request: SentenceAnalysisRequest,
    claims: dict[str, Any] = Depends(get_current_user),
) -> SentenceAnalysisResponse:
    """Analyze German text without storing the submitted learner text."""
    del claims  # Authentication is required; identity is not needed for this stateless operation.
    try:
        return SentenceAnalysisResponse(**analyze_german_text(request.text))
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="German language analysis is temporarily unavailable.",
        ) from exc
