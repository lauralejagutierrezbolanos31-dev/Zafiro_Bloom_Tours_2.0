from fastapi import APIRouter, Depends
from sqlalchemy import select, func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Depto, Destino
from app.schemas.busqueda import ResultadoBusqueda

router = APIRouter(prefix="/buscar", tags=["Buscador"])


@router.get("/", response_model=ResultadoBusqueda)
def buscar(q: str, db: Session = Depends(get_db)):
    patron = f"%{q.strip()}%"
    deptos = db.scalars(
        select(Depto).where(func.unaccent(Depto.nombre).ilike(func.unaccent(patron)))
    ).all()
    destinos = db.scalars(
        select(Destino).where(func.unaccent(Destino.nombre).ilike(func.unaccent(patron)))
    ).all()
    return ResultadoBusqueda(departamentos=deptos, destinos=destinos)