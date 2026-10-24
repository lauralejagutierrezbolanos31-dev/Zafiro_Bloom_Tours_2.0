from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Depto
from app.schemas.depto import DeptoOut

router = APIRouter(prefix="/deptos", tags=["Departamentos"])


@router.get("/", response_model=list[DeptoOut])
def listar_deptos(db: Session = Depends(get_db)):
    return db.scalars(select(Depto).order_by(Depto.nombre)).all()


@router.get("/{id_depto}", response_model=DeptoOut)
def obtener_depto(id_depto: int, db: Session = Depends(get_db)):
    depto = db.get(Depto, id_depto)
    if not depto:
        raise HTTPException(404, "Departamento no encontrado")
    return depto