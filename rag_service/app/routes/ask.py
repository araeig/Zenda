import json
from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db import get_db
from app.models import Embedding
from app.embeddings import embed_text
from app.llm_client import ask_llm, stream_llm

router = APIRouter()

CONTEXT_LIMIT = 8
SOURCE_MAX_DISTANCE = 0.6
SHORT_QUESTION_LENGTH = 60


class HistoryMessage(BaseModel):
    role: str
    content: str


class AskRequest(BaseModel):
    user_id: int
    question: str
    facts: str = ""
    today: str = ""
    history: list[HistoryMessage] = []
    language: str = "ru"


def _history_dicts(request: AskRequest):
    return [{"role": m.role, "content": m.content} for m in request.history]


def _search_text(request: AskRequest):
    previous = [m.content for m in request.history if m.role == "user"]
    if previous and len(request.question) < SHORT_QUESTION_LENGTH:
        return previous[-1] + " " + request.question
    return request.question


def retrieve(db: Session, user_id: int, search_text: str):
    query_vector = embed_text(search_text)
    distance = Embedding.embedding.cosine_distance(query_vector)
    rows = (
        db.query(Embedding, distance.label("distance"))
        .filter(Embedding.user_id == user_id)
        .order_by(distance)
        .limit(CONTEXT_LIMIT)
        .all()
    )

    context = "\n---\n".join(row.Embedding.chunk_text for row in rows) if rows else ""

    sources = []
    seen = set()
    for row in rows:
        key = (row.Embedding.source_type, row.Embedding.source_id)
        if row.distance <= SOURCE_MAX_DISTANCE and key not in seen:
            seen.add(key)
            sources.append({"type": key[0], "id": key[1]})

    return context, sources


@router.post("/ask")
def ask(request: AskRequest, db: Session = Depends(get_db)):
    context, sources = retrieve(db, request.user_id, _search_text(request))
    answer = ask_llm(
        request.question, context, request.facts, request.today, _history_dicts(request), request.language
    )
    return {"status": True, "message": "Успешно", "data": {"answer": answer, "sources": sources}}


@router.post("/ask/stream")
def ask_stream(request: AskRequest, db: Session = Depends(get_db)):
    context, sources = retrieve(db, request.user_id, _search_text(request))
    history = _history_dicts(request)

    def events():
        yield json.dumps({"type": "sources", "sources": sources}, ensure_ascii=False) + "\n"
        try:
            for text in stream_llm(
                request.question, context, request.facts, request.today, history, request.language
            ):
                yield json.dumps({"type": "token", "text": text}, ensure_ascii=False) + "\n"
            yield json.dumps({"type": "done"}) + "\n"
        except Exception as error:
            yield json.dumps({"type": "error", "message": str(error)}, ensure_ascii=False) + "\n"

    return StreamingResponse(events(), media_type="application/x-ndjson")