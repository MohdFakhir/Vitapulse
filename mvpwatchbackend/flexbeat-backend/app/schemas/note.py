import uuid
from datetime import datetime

from pydantic import BaseModel, Field


# ─── Request schemas ──────────────────────────────────────────────────────────

class NoteCreate(BaseModel):
    content: str = Field(..., min_length=1)
    is_voice_note: bool = False


# ─── Response schemas ─────────────────────────────────────────────────────────

class NoteResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    content: str
    is_voice_note: bool
    created_at: datetime

    model_config = {"from_attributes": True}
