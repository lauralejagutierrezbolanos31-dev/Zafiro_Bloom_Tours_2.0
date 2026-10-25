from datetime import date
from decimal import Decimal
from pydantic import BaseModel, ConfigDict, Field, model_validator


class HabitacionPedida(BaseModel):
    id_habitacion: int
    personas: int = Field(ge=1)


class ViajeCrear(BaseModel):
    id_hotel: int
    fecha_inicial: date
    fecha_final: date
    num_personas: int = Field(ge=1, le=60)
    habitaciones: list[HabitacionPedida] = Field(min_length=1)

    @model_validator(mode="after")
    def validar_fechas(self):
        if self.fecha_final <= self.fecha_inicial:
            raise ValueError("La fecha de salida debe ser posterior a la de llegada")
        return self


class HabitacionViajeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_habitacion: int
    nombre_habitacion: str
    personas_asignadas: int
    precio_noche: Decimal


class ViajeOut(BaseModel):
    id_vp: int
    id_destino: int
    nombre_destino: str
    id_hotel: int
    nombre_hotel: str
    fecha_inicial: date
    fecha_final: date
    noches: int
    num_personas: int
    precio: Decimal
    estado: str
    habitaciones: list[HabitacionViajeOut]


class SugerirPeticion(BaseModel):
    id_hotel: int
    fecha_inicial: date
    fecha_final: date
    num_personas: int = Field(ge=1, le=60)


class HabitacionSugerida(BaseModel):
    id_habitacion: int
    nombre: str
    capacidad: int
    personas: int
    precio_noche: Decimal


class SugerenciaOut(BaseModel):
    posible: bool
    mensaje: str
    capacidad_disponible: int
    habitaciones: list[HabitacionSugerida]
    total_estimado: Decimal