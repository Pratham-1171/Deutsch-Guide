from functools import lru_cache
from typing import Any

MODEL_NAME = "de_core_news_sm"


@lru_cache(maxsize=1)
def _load_pipeline():
    """Load the pinned German pipeline once per worker process."""
    try:
        import spacy

        return spacy.load(MODEL_NAME)
    except (ImportError, OSError) as exc:
        raise RuntimeError("The German NLP model is not installed or could not be loaded.") from exc


def analyze_german_text(text: str) -> dict[str, Any]:
    """Return linguistic annotations only; the input text is never persisted."""
    nlp = _load_pipeline()
    doc = nlp(text)

    sentences = [
        {
            "text": sentence.text,
            "start_char": sentence.start_char,
            "end_char": sentence.end_char,
        }
        for sentence in doc.sents
    ]
    tokens = [
        {
            "text": token.text,
            "lemma": token.lemma_,
            "pos": token.pos_,
            "tag": token.tag_,
            "dependency": token.dep_,
            "head_index": token.head.i,
            "head_text": token.head.text,
            "start_char": token.idx,
            "end_char": token.idx + len(token),
            "morphology": token.morph.to_dict(),
            "is_stop_word": token.is_stop,
            "is_punctuation": token.is_punct,
        }
        for token in doc
        if not token.is_space
    ]
    entities = [
        {
            "text": entity.text,
            "label": entity.label_,
            "start_char": entity.start_char,
            "end_char": entity.end_char,
        }
        for entity in doc.ents
    ]

    return {
        "language": "de",
        "model": MODEL_NAME,
        "model_version": str(nlp.meta.get("version", "unknown")),
        "sentences": sentences,
        "tokens": tokens,
        "entities": entities,
    }
