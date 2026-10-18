from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, declarative_base
from pgvector.psycopg2 import register_vector
from app.config import DATABASE_URL

engine = create_engine(DATABASE_URL)


@event.listens_for(engine, "connect")
def connect(dbapi_connection, connection_record):
    register_vector(dbapi_connection)


SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()