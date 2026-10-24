from datetime import date
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, text
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models import Habitacion
from app.schemas.habitacion import HabitacionOut

router = APIRouter(prefix="/habitaciones", tags=["Habitaciones"])


@router.get("/", response_model=list[HabitacionOut])
def listar_habitaciones(
    id_hotel: int,
    fecha_inicial: date | None = None,
    fecha_final: date | None = None,
    db: Session = Depends(get_db),
):
    """Si se envían fechas, 'disponible' indica si la habitación está libre en ese rango."""
    if (fecha_inicial is None) != (fecha_final is None):
        raise HTTPException(400, "Envía fecha_inicial y fecha_final juntas")
    if fecha_inicial and fecha_final and fecha_final <= fecha_inicial:
        raise HTTPException(400, "La fecha de salida debe ser posterior a la de llegada")

    habitaciones = db.scalars(
        select(Habitacion)
        .where(Habitacion.id_hotel == id_hotel)
        .order_by(Habitacion.precio)
    ).all()

    ocupadas: set[int] = set()
    if fecha_inicial and fecha_final:
        filas = db.execute(
            text("""
                SELECT DISTINCT id_habitacion
                FROM viaje_habitacion
                WHERE activa AND fechas && daterange(:ini, :fin, '[)')
            """),
            {"ini": fecha_inicial, "fin": fecha_final},
        )
        ocupadas = {f[0] for f in filas}

    resultado = []
    for h in habitaciones:
        item = HabitacionOut.model_validate(h)
        item.disponible = h.id_habitacion not in ocupadas
        resultado.append(item)
    return resultado