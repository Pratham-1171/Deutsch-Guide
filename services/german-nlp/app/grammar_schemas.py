from typing import Literal

from pydantic import BaseModel


class GrammarReplacement(BaseModel):
    value: str


class GrammarContext(BaseModel):
    text: str
    offset: int
    length: int


class GrammarMatch(BaseModel):
    message: str
    short_message: str
    offset: int
    length: int
    issue_type: str
    rule_id: str
    rule_description: str
    category_id: str
    category_name: str
    context: GrammarContext
    replacements: list[GrammarReplacement]


class GrammarCheckResponse(BaseModel):
    language: Literal["de-DE"]
    engine: Literal["LanguageTool"]
    matches: list[GrammarMatch]
