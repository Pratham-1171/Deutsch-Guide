from functools import lru_cache
from typing import Any

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient, PyJWKClientError
from jwt.exceptions import InvalidTokenError

from app.config import Settings, get_settings

bearer_scheme = HTTPBearer(auto_error=False)


@lru_cache
def _jwks_client(url: str) -> PyJWKClient:
    return PyJWKClient(url, cache_keys=True)


def verify_supabase_token(token: str, settings: Settings) -> dict[str, Any]:
    """Verify an asymmetric Supabase JWT using the project's published JWKS."""
    if not settings.jwks_url or not settings.jwt_issuer:
        raise RuntimeError("Supabase JWT verification is not configured")

    signing_key = _jwks_client(settings.jwks_url).get_signing_key_from_jwt(token)
    claims = jwt.decode(
        token,
        signing_key.key,
        algorithms=settings.allowed_algorithms,
        audience=settings.supabase_jwt_audience,
        issuer=settings.jwt_issuer,
        options={"require": ["exp", "iat", "sub", "iss", "aud"]},
    )
    if not isinstance(claims.get("sub"), str) or not claims["sub"]:
        raise InvalidTokenError("JWT subject is missing")
    return claims


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    settings: Settings = Depends(get_settings),
) -> dict[str, Any]:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="A valid Supabase access token is required.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        return verify_supabase_token(credentials.credentials, settings)
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service is not configured.",
        ) from exc
    except (InvalidTokenError, PyJWKClientError, ValueError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="The supplied access token is invalid or expired.",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc
