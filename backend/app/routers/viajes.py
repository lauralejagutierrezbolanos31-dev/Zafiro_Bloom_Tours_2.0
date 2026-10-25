from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import usuario_actual
from app.models import Usuario
from app.schemas.viaje import SugerenciaOut, SugerirPeticion, ViajeCrear, ViajeOut
from app.services import viaje_service

router = APIRouter(prefix="/viajes", tags=["Viajes"])


@router.post("/sugerir", response_model=SugerenciaOut)
def sugerir_habitaciones(datos: SugerirPeticion, db: Session = Depends(get_db)):
    return viaje_service.sugerir(db, datos)


@router.post("/", response_model=ViajeOut, status_code=201)
def crear_viaje(
    datos: ViajeCrear,
    usuario: Usuario = Depends(usuario_actual),
    db: Session = Depends(get_db),
):
    return viaje_service.crear_viaje(db, usuario, datos)


@router.get("/mis-viajes", response_model=list[ViajeOut])
def mis_viajes(usuario: Usuario = Depends(usuario_actual), db: Session = Depends(get_db)):
    return viaje_service.mis_viajes(db, usuario)


@router.put("/{id_vp}/cancelar", response_model=ViajeOut)
def cancelar_viaje(
    id_vp: int,
    usuario: Usuario = Depends(usuario_actual),
    db: Session = Depends(get_db),
):
    return viaje_service.cancelar_viaje(db, usuario, id_vp)