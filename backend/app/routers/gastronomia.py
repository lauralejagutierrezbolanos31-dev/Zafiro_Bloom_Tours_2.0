from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Gastronomia
from app.schemas.gastronomia import GastronomiaOut

router = APIRouter(prefix="/gastronomia", tags=["Gastronomía"])


@router.get("/", response_model=list[GastronomiaOut])
def listar_gastronomia(id_destino: int, db: Session = Depends(get_db)):
    return db.scalars(
        select(Gastronomia).where(Gastronomia.id_destino == id_destino)
    ).all()