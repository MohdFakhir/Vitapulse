from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..dependencies import get_current_user
from ..models.health_log import HealthLog
from ..models.user import User
from ..schemas.health_log import HealthLogCreate, HealthLogResponse, MetricType, RangeType

router = APIRouter(prefix="/health-logs", tags=["health-logs"])

_RANGE_DELTAS: dict[str, timedelta] = {
    "day": timedelta(days=1),
    "week": timedelta(weeks=1),
    "month": timedelta(days=30),
}


@router.post("", response_model=HealthLogResponse, status_code=status.HTTP_201_CREATED)
def create_health_log(
    payload: HealthLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> HealthLogResponse:
    """Log a new health metric reading for the authenticated user."""
    recorded_at = payload.recorded_at or datetime.now(timezone.utc)

    log = HealthLog(
        user_id=current_user.id,
        metric_type=payload.metric_type,
        value=payload.value,
        unit=payload.unit,
        recorded_at=recorded_at,
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    return HealthLogResponse.model_validate(log)


@router.get("", response_model=list[HealthLogResponse], status_code=status.HTTP_200_OK)
def get_health_logs(
    type: Annotated[MetricType, Query(description="Metric type to filter by")] = "heart_rate",
    range: Annotated[RangeType, Query(description="Time range: day | week | month")] = "week",
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[HealthLogResponse]:
    """
    Return health log history for a given metric type and time range.
    Results are ordered oldest → newest (suitable for charting).
    """
    since = datetime.now(timezone.utc) - _RANGE_DELTAS[range]
    logs = (
        db.query(HealthLog)
        .filter(
            HealthLog.user_id == current_user.id,
            HealthLog.metric_type == type,
            HealthLog.recorded_at >= since,
        )
        .order_by(HealthLog.recorded_at.asc())
        .all()
    )
    return [HealthLogResponse.model_validate(log) for log in logs]
