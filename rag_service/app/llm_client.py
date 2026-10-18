import json
import requests
from app.config import GROQ_API_KEY

GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
MODEL = "openai/gpt-oss-20b"

LANGUAGE_NAMES = {
    "ru": "русском",
    "en": "английском (English)",
    "zh": "китайском (简体中文)",
    "ar": "арабском (العربية)",
}

SYSTEM_PROMPT = """Ты — Zenda, ассистент в приложении-планировщике. Помогаешь человеку разобраться в его проектах, задачах, событиях и заметках.

Как отвечать:
- Отвечай на {language} языке, даже если сведения ниже записаны по-русски. Названия задач, проектов, событий и заметок приводи так, как они записаны.
- Пиши грамотными полными предложениями. Если отвечаешь по-русски, обращайся на «вы».
- Если вопрос о списке (задачи, проекты, события), перечисли все подходящие пункты, а не один.
- Только обычный текст: без таблиц, заголовков, жирного шрифта и любой другой разметки Markdown.
- Если нужен список, пиши каждый пункт с новой строки и начинай его с «• ».
- Даты пиши словами в формате, принятом в языке ответа (по-русски — «2 октября»), время — как «18:00», без секунд.
- Не упоминай слова «контекст», «данные», «записи», «сводка» и «база» — отвечай так, будто просто знаешь планы человека.
- Опирайся только на сведения ниже. Если нужного там нет, коротко скажи, что в планировщике этого нет.
- Учитывай предыдущие сообщения диалога: короткие уточнения вроде «а пример есть?» относятся к предыдущему вопросу.

Понятия в Zenda:
- «Горящие» проекты — активные проекты, у которых срок в ближайшие 7 дней или уже прошёл. В сведениях ниже они помечены словом «горит».
- Просроченная задача — невыполненная задача, срок которой был раньше сегодняшнего дня. В сведениях она помечена «просрочена». Задача со сроком сегодня ещё не просрочена.
- «Итоги недели» — что выполнено за последние 7 дней, что осталось и что запланировано дальше.
- У задач и событий бывают вложения — файлы и ссылки. Их названия и тип есть в сведениях ниже, а отрывки из текста документов — в разделе с заметками, с пометкой «Вложение». Если спрашивают про материалы, примеры или требования, отвечай по этим отрывкам и называй файл, из которого взята информация; открыть его можно в карточке задачи или события. Содержимое видео и ссылок тебе недоступно.

Сейчас: {today}

Текущее состояние планировщика:
{facts}

Заметки и описания, подходящие к вопросу:
{context}"""


def _headers():
    return {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    }


def _payload(question, context, facts, today, history, language, stream):
    system = SYSTEM_PROMPT.format(
        language=LANGUAGE_NAMES.get(language, LANGUAGE_NAMES["ru"]),
        today=today or "неизвестно",
        facts=facts or "Пусто.",
        context=context or "Ничего не найдено.",
    )
    messages = [{"role": "system", "content": system}]
    for message in history or []:
        role = message.get("role")
        content = message.get("content")
        if role in ("user", "assistant") and content:
            messages.append({"role": role, "content": content})
    messages.append({"role": "user", "content": question})

    return {
        "model": MODEL,
        "reasoning_effort": "medium",
        "stream": stream,
        "messages": messages,
    }


def ask_llm(question, context, facts="", today="", history=None, language="ru"):
    response = requests.post(
        GROQ_URL,
        headers=_headers(),
        json=_payload(question, context, facts, today, history, language, False),
        timeout=60,
    )
    response.raise_for_status()
    return response.json()["choices"][0]["message"]["content"]


def stream_llm(question, context, facts="", today="", history=None, language="ru"):
    with requests.post(
        GROQ_URL,
        headers=_headers(),
        json=_payload(question, context, facts, today, history, language, True),
        timeout=60,
        stream=True,
    ) as response:
        response.raise_for_status()
        response.encoding = "utf-8"
        for line in response.iter_lines(decode_unicode=True):
            if not line or not line.startswith("data: "):
                continue
            data = line[len("data: "):]
            if data == "[DONE]":
                break
            chunk = json.loads(data)
            choices = chunk.get("choices") or []
            if not choices:
                continue
            text = (choices[0].get("delta") or {}).get("content")
            if text:
                yield text