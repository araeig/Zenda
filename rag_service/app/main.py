from fastapi import FastAPI
from sqlalchemy import text
from app.db import engine, Base
from app.routes import index, ask, transcribe

app = FastAPI(title="Zenda RAG Service")

app.include_router(index.router)
app.include_router(ask.router)
app.include_router(transcribe.router)


@app.on_event("startup")
def on_startup():
    with engine.connect() as conn:
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        conn.commit()
    Base.metadata.create_all(bind=engine)


@app.get("/")
def health():
    return {"status": True, "message": "rag_service работает", "data": None}