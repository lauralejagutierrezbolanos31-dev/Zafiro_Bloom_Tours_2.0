from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Destino
from app.schemas.destino import DestinoOut

router = APIRouter(prefix="/destinos", tags=["Destinos"])


@router.get("/", response_model=list[DestinoOut])
def listar_destinos(id_depto: int | None = None, db: Session = Depends(get_db)):
    consulta = select(Destino).order_by(Destino.nombre)
    if id_depto is not None:
        consulta = consulta.where(Destino.id_depto == id_depto)
    return db.scalars(consulta).all()


@router.get("/{id_destino}", response_model=DestinoOut)
def obtener_destino(id_destino: int, db: Session = Depends(get_db)):
    destino = db.get(Destino, id_destino)
    if not destino:
        raise HTTPException(404, "Destino no encontrado")
    return destino