from fastapi import APIRouter, File, Form, HTTPException, UploadFile
from app.whisper_client import transcribe_audio

router = APIRouter()

MAX_SIZE = 25 * 1024 * 1024


@router.post("/transcribe")
def transcribe(file: UploadFile = File(...), language: str = Form("ru")):
    data = file.file.read()
    if not data:
        raise HTTPException(status_code=400, detail="Пустая запись")
    if len(data) > MAX_SIZE:
        raise HTTPException(status_code=400, detail="Запись слишком длинная")

    text = transcribe_audio(file.filename or "voice.m4a", data, file.content_type, language)
    return {"status": True, "message": "Успешно", "data": {"text": text}}