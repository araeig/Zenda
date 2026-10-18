import base64
import re
import requests
from app.config import GROQ_API_KEY

VISION_URL = "https://api.groq.com/openai/v1/chat/completions"
VISION_MODEL = "qwen/qwen3.8-27b"

OCR_PROMPT = (
    "Перепиши весь текст с этого изображения страницы документа дословно, на том языке, на котором он написан. "
    "Сохраняй абзацы, нумерацию и списки. Ничего не добавляй от себя, не пересказывай и не описывай "
    "печати, подписи и картинки. Если текста на изображении нет, ответь пустой строкой."
)


def _headers():
    return {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    }


def read_image_text(jpeg_bytes: bytes) -> str:
    encoded = base64.b64encode(jpeg_bytes).decode("ascii")
    payload = {
        "model": VISION_MODEL,
        "temperature": 0,
        "max_completion_tokens": 4096,
        "reasoning_effort": "none",
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": OCR_PROMPT},
                    {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{encoded}"}},
                ],
            }
        ],
    }

    response = requests.post(VISION_URL, headers=_headers(), json=payload, timeout=90)
    if response.status_code == 400:
        payload.pop("reasoning_effort", None)
        response = requests.post(VISION_URL, headers=_headers(), json=payload, timeout=90)
    response.raise_for_status()

    text = response.json()["choices"][0]["message"].get("content") or ""
    text = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL)
    return text.strip()