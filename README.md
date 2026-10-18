# Zenda

Zenda — приложение-планировщик для управления задачами, проектами, событиями и заметками. В приложение входят календарь, вложения, авторизация и AI-ассистент, который отвечает по материалам пользователя.

## Состав проекта

- **`ZendaAPI/`** — REST API и SignalR на ASP.NET Core 8, PostgreSQL и Entity Framework Core.
- **`rag_service/`** — сервис поиска по материалам и генерации ответов на FastAPI, SQLAlchemy и pgvector; для ответов используется Groq API.
- **`zenda_app/`** — клиент Flutter/Dart. Интерфейс локализован на русский, английский, китайский и арабский языки.

## Требования

- .NET 8 SDK
- Python 3.10 или новее
- Flutter SDK, совместимый с ограничением SDK в `zenda_app/pubspec.yaml`
- PostgreSQL с доступным расширением `vector` (pgvector)
- Ключ Groq для функций AI-ассистента

## Настройка PostgreSQL

Создайте базу данных `zenda`. API применяет схему через миграции Entity Framework Core. RAG-сервис при запуске включает расширение `vector` и создаёт собственные таблицы через SQLAlchemy.

Для API настройте локальную конфигурацию, скопировав `ZendaAPI/ZendaAPI/appsettings.example.json` в `ZendaAPI/ZendaAPI/appsettings.Development.json`, затем укажите строку подключения и при необходимости SMTP-настройки. Этот файл исключён из Git. Альтернативно используйте переменные окружения ASP.NET Core, например `ConnectionStrings__DefaultConnection` и `Smtp__Password`.

Примените миграции из каталога API:

```powershell
cd ZendaAPI/ZendaAPI
dotnet tool install --global dotnet-ef
dotnet ef database update
```

Если `dotnet-ef` уже установлен, повторная установка не нужна.

## Запуск RAG-сервиса

В терминале из корня репозитория:

```powershell
cd rag_service
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Заполните `rag_service/.env`: укажите `DATABASE_URL` для PostgreSQL и личный `GROQ_API_KEY`. Затем запустите сервис:

```powershell
uvicorn app.main:app --reload --port 8000
```

Проверка доступности: `http://localhost:8000/`. Интерактивная документация API: `http://localhost:8000/docs`.

## Запуск API

В отдельном терминале:

```powershell
cd ZendaAPI/ZendaAPI
dotnet run
```

Адреса запуска зависят от профиля ASP.NET Core. В режиме разработки Swagger доступен на адресе API в `/swagger`.

## Запуск Flutter-приложения

В третьем терминале:

```powershell
cd zenda_app
flutter pub get
flutter run
```

Адрес API клиента задан в `zenda_app/lib/services/api_client.dart`: Android-эмулятор использует `10.0.2.2`, остальные платформы — `localhost`. При запуске на физическом устройстве замените адрес на IP компьютера в локальной сети; конфигурация API должна совпадать с выбранным адресом и портом.

## Переменные и секреты

Не добавляйте в репозиторий `.env`, `appsettings.Development.json`, реальные строки подключения, SMTP-пароли и API-ключи. Шаблон для Python находится в `rag_service/.env.example`; для API — в `ZendaAPI/ZendaAPI/appsettings.example.json`.

Flutter-приложение обращается только к вашему API: ключ Groq хранится на стороне RAG-сервиса и не должен попадать в Dart-код или собранное приложение. Если действующий ключ уже оказался в публичном репозитории, отзовите его и выпустите новый.

## Структура базы данных

Исходники миграций Entity Framework Core находятся в `ZendaAPI/ZendaAPI/Migrations/`. Их достаточно для развёртывания структуры API-базы; отдельный SQL-дамп схемы не обязателен. Для передачи демонстрационных записей добавьте отдельный обезличенный seed-скрипт или инструкции по наполнению. Не публикуйте дамп с личными данными.

## Что не следует добавлять в Git

Не включайте виртуальные окружения, кэши, каталоги сборки, локальные настройки IDE, локальные конфигурации с секретами и пользовательские загруженные файлы. Корневой `.gitignore` уже содержит основные такие исключения.

---

# Zenda (English)

Zenda is a planner for managing tasks, projects, events, and notes. It includes a calendar, file attachments, authentication, and an AI assistant that answers questions using the user's materials.

## Project components

- **`ZendaAPI/`** — REST API and SignalR service built with ASP.NET Core 8, PostgreSQL, and Entity Framework Core.
- **`rag_service/`** — a FastAPI service for searching user materials and generating answers with SQLAlchemy and pgvector; Groq API is used for AI responses.
- **`zenda_app/`** — the Flutter/Dart client. The interface is localized in Russian, English, Chinese, and Arabic.

## Requirements

- .NET 8 SDK
- Python 3.10 or later
- Flutter SDK compatible with the SDK constraint in `zenda_app/pubspec.yaml`
- PostgreSQL with the `vector` extension (pgvector) available
- A Groq API key for the AI assistant

## PostgreSQL setup

Create a PostgreSQL database named `zenda`. The API applies its schema using Entity Framework Core migrations. On startup, the RAG service enables the `vector` extension and creates its own tables through SQLAlchemy.

For the API, copy `ZendaAPI/ZendaAPI/appsettings.example.json` to `ZendaAPI/ZendaAPI/appsettings.Development.json`, then configure the database connection and, if needed, SMTP settings. This local file is excluded from Git. Alternatively, configure ASP.NET Core environment variables such as `ConnectionStrings__DefaultConnection` and `Smtp__Password`.

Apply the API migrations:

```powershell
cd ZendaAPI/ZendaAPI
dotnet tool install --global dotnet-ef
dotnet ef database update
```

Skip the tool installation if `dotnet-ef` is already installed.

## Run the RAG service

From the repository root, run:

```powershell
cd rag_service
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Fill in `rag_service/.env` with your PostgreSQL `DATABASE_URL` and personal `GROQ_API_KEY`, then start the service:

```powershell
uvicorn app.main:app --reload --port 8000
```

Health check: `http://localhost:8000/`. Interactive API documentation: `http://localhost:8000/docs`.

## Run the API

In a separate terminal, run:

```powershell
cd ZendaAPI/ZendaAPI
dotnet run
```

The actual addresses depend on the ASP.NET Core launch profile. In Development mode, Swagger is available at the API address followed by `/swagger`.

## Run the Flutter application

In a third terminal, run:

```powershell
cd zenda_app
flutter pub get
flutter run
```

The API address is configured in `zenda_app/lib/services/api_client.dart`: the Android emulator uses `10.0.2.2`, while other platforms use `localhost`. For a physical device, replace the address with your computer's local network IP and make sure the API is configured to use the matching address and port.

## Configuration and secrets

Do not commit `.env`, `appsettings.Development.json`, real database connection strings, SMTP passwords, or API keys. The Python template is `rag_service/.env.example`; the API template is `ZendaAPI/ZendaAPI/appsettings.example.json`.

The Flutter application communicates with your API. Keep the Groq key on the RAG service and out of the Dart code and built application. If an active key has already been published in a public repository, revoke it and create a new one.

## Database schema

Entity Framework Core migration sources are in `ZendaAPI/ZendaAPI/Migrations/`. They are sufficient to create the API database schema; a separate SQL schema dump is not required. To share sample records, add a separate anonymized seed script or setup instructions. Do not publish a database dump containing personal data.

## Files to keep out of Git

Do not commit virtual environments, caches, build output, local IDE settings, local configuration containing secrets, or user-uploaded files. The root `.gitignore` already contains the main exclusions.
