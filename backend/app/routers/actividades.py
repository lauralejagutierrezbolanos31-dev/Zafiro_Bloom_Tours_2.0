from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Actividad
from app.schemas.actividad import ActividadOut

router = APIRouter(prefix="/actividades", tags=["Actividades"])


@router.get("/", response_model=list[ActividadOut])
def listar_actividades(id_destino: int, db: Session = Depends(get_db)):
    return db.scalars(
        select(Actividad).where(Actividad.id_destino == id_destino)
    ).all()