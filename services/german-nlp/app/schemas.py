from typing import Literal

from pydantic import BaseModel, Field, field_validator


class SentenceAnalysisRequest(BaseModel):
    text: str = Field(min_length=1, max_length=2000)

    @field_validator("text")
    @classmethod
    def text_must_contain_non_whitespace(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Text must contain at least one non-whitespace character.")
        return value


class SentenceSpan(BaseModel):
    text: str
    start_char: int
    end_char: int


class TokenAnalysis(BaseModel):
    text: str
    lemma: str
    pos: str
    tag: str
    dependency: str
    head_index: int
    head_text: str
    start_char: int
    end_char: int
    morphology: dict[str, str]
    is_stop_word: bool
    is_punctuation: bool


class EntityAnalysis(BaseModel):
    text: str
    label: str
    start_char: int
    end_char: int


class SentenceAnalysisResponse(BaseModel):
    language: Literal["de"]
    model: str
    model_version: str
    sentences: list[SentenceSpan]
    tokens: list[TokenAnalysis]
    entities: list[EntityAnalysis]
