import unicodedata

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Depto, Destino
from app.schemas.busqueda import ResultadoBusqueda

router = APIRouter(prefix="/buscar", tags=["Buscador"])


def normalizar(texto: str) -> str:
    """Minúsculas y sin tildes: 'Nariño' -> 'narino'."""
    sin_tildes = unicodedata.normalize("NFD", texto.lower())
    return "".join(c for c in sin_tildes if unicodedata.category(c) != "Mn")


@router.get("/", response_model=ResultadoBusqueda)
def buscar(q: str, db: Session = Depends(get_db)):
    termino = normalizar(q.strip())
    if not termino:
        return ResultadoBusqueda(departamentos=[], destinos=[])

    deptos = db.scalars(select(Depto).order_by(Depto.nombre)).all()
    destinos = db.scalars(select(Destino).order_by(Destino.nombre)).all()

    deptos_ok = [d for d in deptos if termino in normalizar(d.nombre)]
    ids_deptos_ok = {d.id_depto for d in deptos_ok}
    destinos_ok = [
        d for d in destinos
        if termino in normalizar(d.nombre) or d.id_depto in ids_deptos_ok
    ]
    return ResultadoBusqueda(departamentos=deptos_ok, destinos=destinos_ok)