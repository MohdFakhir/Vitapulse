import uuid
from datetime import datetime, time

from pydantic import BaseModel, Field


# ─── Request schemas ──────────────────────────────────────────────────────────

class ReminderCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    reminder_time: time  # ISO format HH:MM:SS or HH:MM
    repeat_daily: bool = True


# ─── Response schemas ─────────────────────────────────────────────────────────

class ReminderResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    title: str
    reminder_time: time
    repeat_daily: bool
    created_at: datetime

    model_config = {"from_attributes": True}
