from sentence_transformers import SentenceTransformer
from app.config import EMBEDDING_MODEL

model = SentenceTransformer(EMBEDDING_MODEL)


def embed_text(text: str) -> list[float]:
    return model.encode(text).tolist()


def embed_texts(texts: list[str]) -> list[list[float]]:
    return model.encode(texts).tolist()