from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Feria
from app.schemas.feria import FeriaOut

router = APIRouter(prefix="/ferias", tags=["Ferias y Ofertas"])


@router.get("/", response_model=list[FeriaOut])
def listar_ferias(tipo: str | None = None, db: Session = Depends(get_db)):
    consulta = select(Feria).where(Feria.activo.is_(True)).order_by(Feria.fecha_inicio)
    if tipo in ("feria", "oferta"):
        consulta = consulta.where(Feria.tipo == tipo)
    ferias = db.scalars(consulta).all()

    return [
        FeriaOut(
            id_feria=f.id_feria,
            nombre=f.nombre,
            tipo=f.tipo,
            descripcion=f.descripcion,
            foto_referencia=f.foto_referencia,
            fecha_inicio=f.fecha_inicio,
            fecha_fin=f.fecha_fin,
            descuento_porcentaje=f.descuento_porcentaje,
            nombre_depto=f.depto.nombre if f.depto else None,
            nombre_destino=f.destino.nombre if f.destino else None,
        )
        for f in ferias
    ]