import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

MetricType = Literal["heart_rate", "steps", "calories", "sleep", "running", "water"]
UnitType = Literal["bpm", "steps", "kcal", "hours", "km", "liters"]
RangeType = Literal["day", "week", "month"]


# ─── Request schemas ──────────────────────────────────────────────────────────

class HealthLogCreate(BaseModel):
    metric_type: MetricType
    value: float = Field(..., ge=0)
    unit: UnitType
    recorded_at: datetime | None = None  # defaults to server time if omitted


# ─── Response schemas ─────────────────────────────────────────────────────────

class HealthLogResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    metric_type: str
    value: float
    unit: str
    recorded_at: datetime

    model_config = {"from_attributes": True}
