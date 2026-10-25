from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import requiere_rol
from app.models import Usuario
from app.schemas.feria import FeriaAdminOut, FeriaGuardar
from app.services import feria_service

router = APIRouter(prefix="/admin/ferias", tags=["Panel Super Administrador: ferias"])

solo_super = requiere_rol("super_admin")


@router.get("/", response_model=list[FeriaAdminOut])
def listar(tipo: str | None = None, _: Usuario = Depends(solo_super), db: Session = Depends(get_db)):
    return feria_service.listar(db, tipo)


@router.post("/", response_model=FeriaAdminOut, status_code=201)
def crear(datos: FeriaGuardar, _: Usuario = Depends(solo_super), db: Session = Depends(get_db)):
    return feria_service.crear(db, datos)


@router.put("/{id_feria}", response_model=FeriaAdminOut)
def actualizar(
    id_feria: int, datos: FeriaGuardar,
    _: Usuario = Depends(solo_super), db: Session = Depends(get_db),
):
    return feria_service.actualizar(db, id_feria, datos)


@router.delete("/{id_feria}", status_code=204)
def eliminar(id_feria: int, _: Usuario = Depends(solo_super), db: Session = Depends(get_db)):
    feria_service.eliminar(db, id_feria)