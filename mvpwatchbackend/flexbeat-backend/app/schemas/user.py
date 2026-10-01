import uuid
from datetime import date, datetime

from pydantic import BaseModel, EmailStr, Field, field_validator


# ─── Request schemas ──────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    gender: str = Field(..., min_length=1, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=6)
    date_of_birth: date
    weight: float = Field(..., gt=0)
    height: float = Field(..., gt=0)
    water_goal_liters: float = Field(..., gt=0)

    @field_validator("gender")
    @classmethod
    def gender_must_be_valid(cls, v: str) -> str:
        allowed = {"Male", "Female", "Other"}
        if v not in allowed:
            raise ValueError(f"gender must be one of {allowed}")
        return v


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=255)
    gender: str | None = Field(default=None, min_length=1, max_length=50)
    weight: float | None = Field(default=None, gt=0)
    height: float | None = Field(default=None, gt=0)
    water_goal_liters: float | None = Field(default=None, gt=0)


# ─── Response schemas ─────────────────────────────────────────────────────────

class UserResponse(BaseModel):
    id: uuid.UUID
    name: str
    gender: str
    email: str
    date_of_birth: date
    age: int
    weight: float
    height: float
    water_goal_liters: float
    created_at: datetime

    model_config = {"from_attributes": True}


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
