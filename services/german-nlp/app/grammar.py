from typing import Any

import httpx

from app.config import Settings


class GrammarServiceUnavailable(RuntimeError):
    """Raised when the configured LanguageTool service cannot be reached."""


def _normalize_match(match: dict[str, Any]) -> dict[str, Any]:
    rule = match.get("rule") or {}
    category = rule.get("category") or {}
    context = match.get("context") or {}
    replacements = match.get("replacements") or []

    issue_type = match.get("type") or match.get("issueType") or "unknown"
    if isinstance(issue_type, dict):
        issue_type = issue_type.get("typeName") or "unknown"

    return {
        "message": str(match.get("message") or ""),
        "short_message": str(match.get("shortMessage") or ""),
        "offset": int(match.get("offset") or 0),
        "length": int(match.get("length") or 0),
        "issue_type": str(issue_type),
        "rule_id": str(rule.get("id") or ""),
        "rule_description": str(rule.get("description") or ""),
        "category_id": str(category.get("id") or ""),
        "category_name": str(category.get("name") or ""),
        "context": {
            "text": str(context.get("text") or ""),
            "offset": int(context.get("offset") or 0),
            "length": int(context.get("length") or 0),
        },
        "replacements": [
            {"value": str(item.get("value") or "")}
            for item in replacements[:5]
            if isinstance(item, dict)
        ],
    }


async def check_german_grammar(text: str, settings: Settings) -> dict[str, Any]:
    """Call a configured LanguageTool-compatible server; never persist submitted text."""
    if not settings.languagetool_url:
        raise GrammarServiceUnavailable("LanguageTool service URL is not configured")

    url = f"{settings.languagetool_url.rstrip('/')}/v2/check"
    try:
        async with httpx.AsyncClient(
            timeout=settings.languagetool_timeout_seconds,
            follow_redirects=False,
        ) as client:
            response = await client.post(
                url,
                data={"text": text, "language": "de-DE"},
                headers={"Accept": "application/json"},
            )
            response.raise_for_status()
            payload = response.json()
    except (httpx.HTTPError, ValueError) as exc:
        raise GrammarServiceUnavailable("LanguageTool request failed") from exc

    if not isinstance(payload, dict) or not isinstance(payload.get("matches"), list):
        raise GrammarServiceUnavailable("LanguageTool returned an invalid response")

    return {
        "language": "de-DE",
        "engine": "LanguageTool",
        "matches": [
            _normalize_match(item)
            for item in payload["matches"]
            if isinstance(item, dict)
        ],
    }
