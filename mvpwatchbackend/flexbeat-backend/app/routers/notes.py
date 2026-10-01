from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..dependencies import get_current_user
from ..models.note import HealthNote
from ..models.user import User
from ..schemas.note import NoteCreate, NoteResponse

router = APIRouter(prefix="/notes", tags=["notes"])


@router.post("", response_model=NoteResponse, status_code=status.HTTP_201_CREATED)
def create_note(
    payload: NoteCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> NoteResponse:
    """Create a new health note (text or transcribed voice note)."""
    note = HealthNote(
        user_id=current_user.id,
        content=payload.content,
        is_voice_note=payload.is_voice_note,
    )
    db.add(note)
    db.commit()
    db.refresh(note)
    return NoteResponse.model_validate(note)


@router.get("", response_model=list[NoteResponse], status_code=status.HTTP_200_OK)
def get_notes(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[NoteResponse]:
    """List the authenticated user's notes, most recent first."""
    notes = (
        db.query(HealthNote)
        .filter(HealthNote.user_id == current_user.id)
        .order_by(HealthNote.created_at.desc())
        .all()
    )
    return [NoteResponse.model_validate(n) for n in notes]
