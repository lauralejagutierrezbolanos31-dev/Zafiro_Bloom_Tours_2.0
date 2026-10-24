from decimal import Decimal
from pydantic import BaseModel, ConfigDict


class HabitacionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_habitacion: int
    id_hotel: int
    nombre: str
    descripcion: str | None = None
    tipo_cama: str | None = None
    capacidad: int
    precio: Decimal
    foto_referencia: str | None = None
    disponible: bool = True  # se calcula según las fechas pedidas