from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .core.database import Base, engine
from .routers import auth, health_logs, notes, profile, reminders

# ─── Create tables (idempotent — skipped if tables already exist) ─────────────
# In production, prefer Alembic migrations. This is a safety net for dev.
Base.metadata.create_all(bind=engine)

# ─── App ─────────────────────────────────────────────────────────────────────

app = FastAPI(
    title="Flex Beat API",
    description="Health tracking backend for the Flex Beat app by Wormhole.ai",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ─── CORS — allow all origins for local dev / Flutter on-device testing ───────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Routers ─────────────────────────────────────────────────────────────────

app.include_router(auth.router)
app.include_router(profile.router)
app.include_router(health_logs.router)
app.include_router(notes.router)
app.include_router(reminders.router)


# ─── Health check ─────────────────────────────────────────────────────────────

@app.get("/", tags=["root"])
def root() -> dict[str, str]:
    return {"status": "ok", "message": "Flex Beat API is running 🚀"}
