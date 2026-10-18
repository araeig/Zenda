from sqlalchemy import Column, Integer, String, Text
from pgvector.sqlalchemy import Vector
from app.db import Base


class Embedding(Base):
    __tablename__ = "embeddings"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False, index=True)
    source_type = Column(String(20), nullable=False)
    source_id = Column(Integer, nullable=False)
    chunk_text = Column(Text, nullable=False)
    embedding = Column(Vector(384), nullable=False)