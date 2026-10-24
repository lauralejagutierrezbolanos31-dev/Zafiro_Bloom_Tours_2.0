from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Transporte
from app.schemas.transporte import TransporteOut

router = APIRouter(prefix="/transporte", tags=["Transporte"])


@router.get("/", response_model=list[TransporteOut])
def listar_transporte(id_destino: int, db: Session = Depends(get_db)):
    return db.scalars(
        select(Transporte).where(Transporte.id_destino == id_destino)
    ).all()