from datetime import date

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..dependencies import get_current_user
from ..models.user import User
from ..schemas.user import UserResponse, UserUpdate

router = APIRouter(prefix="/profile", tags=["profile"])


def _compute_age(dob: date) -> int:
    today = date.today()
    return today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))


@router.get("/me", response_model=UserResponse, status_code=status.HTTP_200_OK)
def get_profile(current_user: User = Depends(get_current_user)) -> UserResponse:
    """Return the authenticated user's profile."""
    return UserResponse.model_validate(current_user)


@router.put("/me", response_model=UserResponse, status_code=status.HTTP_200_OK)
def update_profile(
    payload: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> UserResponse:
    """Update mutable profile fields for the authenticated user."""
    update_data = payload.model_dump(exclude_none=True)
    for field, value in update_data.items():
        setattr(current_user, field, value)

    # Recompute age if DOB changed (not exposed in UserUpdate but kept safe)
    current_user.age = _compute_age(current_user.date_of_birth)

    db.commit()
    db.refresh(current_user)
    return UserResponse.model_validate(current_user)
