# Flex Beat — Python Backend

FastAPI + PostgreSQL backend for the **Flex Beat** health app by Wormhole.ai.

---

## Tech Stack

| Layer | Library |
|---|---|
| API framework | FastAPI |
| ASGI server | Uvicorn |
| ORM | SQLAlchemy 2.x |
| Migrations | Alembic |
| Database | PostgreSQL |
| Password hashing | passlib[bcrypt] |
| JWT tokens | python-jose |
| Config / env | pydantic-settings + python-dotenv |

---

## Project Structure

```
flexbeat-backend/
  app/
    main.py            ← FastAPI app, CORS, router registration
    core/
      config.py        ← Settings loaded from .env
      security.py      ← bcrypt hashing + JWT helpers
      database.py      ← SQLAlchemy engine, session, Base
    models/            ← ORM table definitions
    schemas/           ← Pydantic request/response models
    routers/           ← Route handlers (auth, profile, health-logs, notes, reminders)
    dependencies.py    ← get_current_user JWT dependency
  alembic/             ← Migration scripts
  alembic.ini
  requirements.txt
  .env.example
```

---

## Local Setup

### 1. Create the PostgreSQL database

Make sure PostgreSQL is running locally, then:

```bash
# Open psql as your superuser (adjust username if needed)
psql -U postgres

# Inside psql:
CREATE DATABASE flexbeat_db;
\q
```

### 2. Clone / open the project and create your `.env`

```bash
cd flexbeat-backend
cp .env.example .env
```

Edit `.env` and fill in your real credentials:

```env
DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/flexbeat_db
JWT_SECRET_KEY=replace_with_a_long_random_string
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
```

> **Tip — generate a strong secret:**
> ```bash
> python -c "import secrets; print(secrets.token_hex(32))"
> ```

### 3. Create a virtual environment & install dependencies

```bash
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt

# pydantic-settings is needed for config.py
pip install pydantic-settings
```

### 4. Run Alembic migrations (creates all tables)

```bash
alembic upgrade head
```

Expected output:
```
INFO  [alembic.runtime.migration] Running upgrade  -> 0001_initial, Initial schema
```

### 5. Start the development server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API is now available at:
- **http://localhost:8000** — health check (`{"status":"ok"}`)
- **http://localhost:8000/docs** — interactive Swagger UI
- **http://localhost:8000/redoc** — ReDoc documentation

---

## API Reference

### Auth (no token required)

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/register` | Register a new user, returns JWT |
| POST | `/auth/login` | Login, returns JWT |

### Protected routes (Bearer token required)

| Method | Endpoint | Description |
|---|---|---|
| GET | `/profile/me` | Get current user profile |
| PUT | `/profile/me` | Update profile fields |
| POST | `/health-logs` | Log a new health metric |
| GET | `/health-logs?type=heart_rate&range=week` | Get metric history |
| POST | `/notes` | Create a health note |
| GET | `/notes` | List all notes (newest first) |
| POST | `/reminders` | Create a reminder |
| GET | `/reminders` | List all reminders |
| DELETE | `/reminders/{id}` | Delete a reminder |

### `metric_type` values
`heart_rate` · `steps` · `calories` · `sleep` · `running` · `water`

### `range` values
`day` · `week` · `month`

---

## Testing with curl

```bash
# 1. Register
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "gender": "Male",
    "email": "test@example.com",
    "password": "secret123",
    "date_of_birth": "1995-06-15",
    "weight": 75.0,
    "height": 175.0,
    "water_goal_liters": 2.5
  }'

# 2. Login — copy access_token from response
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "secret123"}'

# Set token in your shell:
TOKEN="<paste_access_token_here>"

# 3. Get profile
curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/profile/me

# 4. Log a heart rate reading
curl -X POST http://localhost:8000/health-logs \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"metric_type": "heart_rate", "value": 72.0, "unit": "bpm"}'

# 5. Get heart rate history (last week)
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/health-logs?type=heart_rate&range=week"

# 6. Create a note
curl -X POST http://localhost:8000/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Felt great after morning run!", "is_voice_note": false}'

# 7. Create a reminder
curl -X POST http://localhost:8000/reminders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Drink water", "reminder_time": "08:00:00", "repeat_daily": true}'
```

---

## Connecting from Flutter (on-device)

1. Find your machine's local IP: `ipconfig` on Windows → look for **IPv4 Address**
2. Set the base URL in your Flutter app to `http://<your-local-ip>:8000`
3. Make sure your phone and PC are on the same WiFi network
4. The server must be running with `--host 0.0.0.0` (already the default in the command above)

---

## Next Steps

- [ ] Replace Flutter mock repositories with HTTP calls to this API
- [ ] Add refresh tokens for production
- [ ] Deploy to Render / Railway / VPS and update Flutter base URL
- [ ] Switch CORS `allow_origins` from `["*"]` to specific production URLs
