# Third-party notices

## spaCy

- Package: `spacy==3.8.18`
- License: MIT
- Project: https://github.com/explosion/spaCy
- Release information: https://github.com/explosion/spaCy/releases/tag/v3.8.18

## German language pipeline

- Package: `de_core_news_sm==3.8.0`
- Model: https://github.com/explosion/spacy-models/releases/tag/de_core_news_sm-3.8.0
- Model metadata: https://github.com/explosion/spacy-models/blob/master/meta/de_core_news_sm-3.8.0.json
- Model license declared by upstream metadata: MIT
- Model wheel SHA-256 declared by upstream metadata: `fec69fec52b1780f2d269d5af7582a5e28028738bd3190532459aeb473bfa3e7`

Upstream model metadata lists these training/evaluation sources and notices:

- TIGER Corpus: commercially licensed by Explosion. The corpus itself is not included in this repository or the model wheel.
- WikiNER: CC BY 4.0.
- Tiger2Dep: citation/reference notice; no code is packaged with the model.

The model's MIT declaration does not grant rights to redistribute the original source corpora. Keep the upstream model license and source notices with any redistributed service image or deployment artifact, and review the current upstream terms before commercial redistribution or material changes to distribution.

## PyJWT

- Package: `PyJWT[crypto]==2.10.1`
- License: MIT
- Project: https://github.com/jpadilla/pyjwt

## FastAPI and runtime dependencies

The pinned runtime packages declare their respective licenses in their package metadata. Preserve their notices when redistributing a bundled runtime. This file is an attribution index, not a replacement for the complete license texts shipped by those packages.
