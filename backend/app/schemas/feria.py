from datetime import date
from decimal import Decimal
from pydantic import BaseModel


class FeriaOut(BaseModel):
    id_feria: int
    nombre: str
    tipo: str
    descripcion: str | None = None
    foto_referencia: str | None = None
    fecha_inicio: date | None = None
    fecha_fin: date | None = None
    descuento_porcentaje: Decimal | None = None
    nombre_depto: str | None = None
    nombre_destino: str | None = None