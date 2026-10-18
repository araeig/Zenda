from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db import get_db
from app.models import Embedding
from app.embeddings import embed_text, embed_texts
from app.text_extract import extract_text, split_chunks

router = APIRouter()


class IndexRequest(BaseModel):
    user_id: int
    source_type: str
    source_id: int
    text: str


def _same_source(db: Session, user_id: int, source_type: str, source_id: int):
    return db.query(Embedding).filter(
        Embedding.user_id == user_id,
        Embedding.source_type == source_type,
        Embedding.source_id == source_id,
    )


@router.post("/index")
def index_text(request: IndexRequest, db: Session = Depends(get_db)):
    vector = embed_text(request.text)

    _same_source(db, request.user_id, request.source_type, request.source_id).delete()

    row = Embedding(
        user_id=request.user_id,
        source_type=request.source_type,
        source_id=request.source_id,
        chunk_text=request.text,
        embedding=vector,
    )
    db.add(row)
    db.commit()

    return {"status": True, "message": "Проиндексировано", "data": {"id": row.id}}


@router.post("/index/file")
def index_file(
    user_id: int = Form(...),
    source_id: int = Form(...),
    title: str = Form(""),
    owner: str = Form(""),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    data = file.file.read()
    text = extract_text(file.filename or "", data)
    chunks = split_chunks(text) if text else []

    _same_source(db, user_id, "attachment", source_id).delete()

    if chunks:
        vectors = embed_texts(chunks)
        header = f"Вложение «{title}»" + (f" {owner}" if owner else "")
        for number, (chunk, vector) in enumerate(zip(chunks, vectors), start=1):
            db.add(Embedding(
                user_id=user_id,
                source_type="attachment",
                source_id=source_id,
                chunk_text=f"{header}, фрагмент {number}: {chunk}",
                embedding=vector,
            ))
    db.commit()

    print(f"Indexed attachment {source_id}: {len(chunks)} chunks")
    return {"status": True, "message": "Проиндексировано", "data": {"chunks": len(chunks)}}


@router.delete("/index")
def delete_index(user_id: int, source_type: str, source_id: int, db: Session = Depends(get_db)):
    deleted = _same_source(db, user_id, source_type, source_id).delete()
    db.commit()

    return {"status": True, "message": "Удалено", "data": {"deleted": deleted}}