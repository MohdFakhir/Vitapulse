import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..dependencies import get_current_user
from ..models.reminder import Reminder
from ..models.user import User
from ..schemas.reminder import ReminderCreate, ReminderResponse

router = APIRouter(prefix="/reminders", tags=["reminders"])


@router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
def create_reminder(
    payload: ReminderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ReminderResponse:
    """Create a new reminder for the authenticated user."""
    reminder = Reminder(
        user_id=current_user.id,
        title=payload.title,
        reminder_time=payload.reminder_time,
        repeat_daily=payload.repeat_daily,
    )
    db.add(reminder)
    db.commit()
    db.refresh(reminder)
    return ReminderResponse.model_validate(reminder)


@router.get("", response_model=list[ReminderResponse], status_code=status.HTTP_200_OK)
def get_reminders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[ReminderResponse]:
    """List all reminders for the authenticated user, ordered by reminder time."""
    reminders = (
        db.query(Reminder)
        .filter(Reminder.user_id == current_user.id)
        .order_by(Reminder.reminder_time.asc())
        .all()
    )
    return [ReminderResponse.model_validate(r) for r in reminders]


@router.delete("/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_reminder(
    reminder_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    """Delete a reminder by ID (must belong to the authenticated user)."""
    reminder = (
        db.query(Reminder)
        .filter(Reminder.id == reminder_id, Reminder.user_id == current_user.id)
        .first()
    )
    if reminder is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reminder not found",
        )
    db.delete(reminder)
    db.commit()
