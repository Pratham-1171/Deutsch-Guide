from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime configuration. Secrets must be injected by the deployment platform."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    service_name: str = "deutsch-guide-german-nlp"
    environment: str = "development"
    api_prefix: str = "/api/v1"
    supabase_url: str = ""
    supabase_jwks_url: str = ""
    supabase_jwt_issuer: str = ""
    supabase_jwt_audience: str = "authenticated"
    supabase_jwt_algorithms: str = "ES256,RS256,ES384,ES512,EdDSA"

    @property
    def jwks_url(self) -> str:
        if self.supabase_jwks_url:
            return self.supabase_jwks_url
        if self.supabase_url:
            return f"{self.supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"
        return ""

    @property
    def jwt_issuer(self) -> str:
        if self.supabase_jwt_issuer:
            return self.supabase_jwt_issuer
        if self.supabase_url:
            return f"{self.supabase_url.rstrip('/')}/auth/v1"
        return ""

    @property
    def allowed_algorithms(self) -> list[str]:
        return [item.strip() for item in self.supabase_jwt_algorithms.split(",") if item.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
