import asyncio

import httpx
import pytest

from app.config import Settings
from app.grammar import GrammarServiceUnavailable, check_german_grammar


def test_grammar_check_normalizes_language_tool_matches(monkeypatch) -> None:
    payload = {
        "matches": [
            {
                "message": "Verbform prüfen",
                "shortMessage": "Verb",
                "offset": 3,
                "length": 4,
                "type": "Other",
                "rule": {
                    "id": "DE_TEST",
                    "description": "Test rule",
                    "category": {"id": "GRAMMAR", "name": "Grammar"},
                },
                "context": {"text": "Ich gehen.", "offset": 3, "length": 4},
                "replacements": [
                    {"value": "gehe"},
                    {"value": "ging"},
                    {"value": "gehe"},
                    {"value": "gehe"},
                    {"value": "gehe"},
                    {"value": "gehe"},
                ],
            }
        ]
    }

    class FakeResponse:
        def raise_for_status(self):
            return None

        def json(self):
            return payload

    class FakeClient:
        def __init__(self, **kwargs):
            assert kwargs["timeout"] == 8.0
            assert kwargs["follow_redirects"] is False

        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return None

        async def post(self, url, *, data, headers):
            assert url == "http://grammar.internal:8010/v2/check"
            assert data == {"text": "Ich gehen.", "language": "de-DE"}
            assert headers["Accept"] == "application/json"
            return FakeResponse()

    monkeypatch.setattr("app.grammar.httpx.AsyncClient", FakeClient)

    result = asyncio.run(
        check_german_grammar(
            "Ich gehen.",
            Settings(languagetool_url="http://grammar.internal:8010"),
        )
    )

    assert result["language"] == "de-DE"
    assert result["engine"] == "LanguageTool"
    assert result["matches"][0]["rule_id"] == "DE_TEST"
    assert len(result["matches"][0]["replacements"]) == 5


def test_grammar_check_requires_configured_server() -> None:
    with pytest.raises(GrammarServiceUnavailable, match="not configured"):
        __import__("asyncio").run(check_german_grammar("Ich gehe.", Settings()))


def test_grammar_check_wraps_transport_errors(monkeypatch) -> None:
    class FakeClient:
        def __init__(self, **kwargs):
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return None

        async def post(self, *args, **kwargs):
            raise httpx.ConnectError("offline")

    monkeypatch.setattr("app.grammar.httpx.AsyncClient", FakeClient)

    with pytest.raises(GrammarServiceUnavailable, match="request failed"):
        __import__("asyncio").run(
            check_german_grammar(
                "Ich gehe.",
                Settings(languagetool_url="http://grammar.internal:8010"),
            )
        )
