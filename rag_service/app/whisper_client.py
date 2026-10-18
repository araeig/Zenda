import requests
from app.config import GROQ_API_KEY

WHISPER_URL = "https://api.groq.com/openai/v1/audio/transcriptions"
WHISPER_MODEL = "whisper-large-v3-turbo"


def transcribe_audio(filename, data, content_type, language="ru"):
    response = requests.post(
        WHISPER_URL,
        headers={
            "Authorization": f"Bearer {GROQ_API_KEY}",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        },
        files={"file": (filename, data, content_type or "application/octet-stream")},
        data={
            "model": WHISPER_MODEL,
            "language": language,
            "response_format": "json",
            "temperature": "0",
        },
        timeout=60,
    )
    response.raise_for_status()
    return response.json().get("text", "").strip()