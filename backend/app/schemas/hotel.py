from decimal import Decimal
from pydantic import BaseModel, ConfigDict


class HotelOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_hotel: int
    id_destino: int
    nombre: str
    foto_referencia: str | None = None
    direccion: str | None = None
    descripcion: str | None = None
    contacto: str | None = None
    categoria: str | None = None
    total_habitaciones: int
    habitaciones_ocupadas: int
    precio_promedio: Decimal
    porcentaje_ocupacion: Decimal