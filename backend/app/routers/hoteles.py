from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Hotel
from app.schemas.hotel import HotelOut

router = APIRouter(prefix="/hoteles", tags=["Hoteles"])


@router.get("/", response_model=list[HotelOut])
def listar_hoteles(id_destino: int | None = None, db: Session = Depends(get_db)):
    consulta = select(Hotel).order_by(Hotel.nombre)
    if id_destino is not None:
        consulta = consulta.where(Hotel.id_destino == id_destino)
    return db.scalars(consulta).all()


@router.get("/{id_hotel}", response_model=HotelOut)
def obtener_hotel(id_hotel: int, db: Session = Depends(get_db)):
    hotel = db.get(Hotel, id_hotel)
    if not hotel:
        raise HTTPException(404, "Hotel no encontrado")
    return hotel