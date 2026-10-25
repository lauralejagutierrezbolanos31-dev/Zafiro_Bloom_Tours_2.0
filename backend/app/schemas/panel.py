from datetime import date, datetime
from decimal import Decimal
from pydantic import BaseModel, ConfigDict, Field


class SolicitudAdminOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_solicitud: int
    nombre: str
    apellidos: str | None = None
    documento: str
    cargo: str
    correo: str
    telefono: str | None = None
    nombre_hotel: str
    direccion_hotel: str
    contacto_hotel: str
    categoria: str
    descripcion: str
    politicas: str
    id_destino: int | None = None
    estado: str
    fecha_registro: datetime


class ResolverSolicitud(BaseModel):
    id_destino: int | None = None  # el super admin puede asignar el destino al aprobar


class HotelPanelOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_hotel: int
    id_destino: int
    nombre: str
    direccion: str | None = None
    descripcion: str | None = None
    contacto: str | None = None
    categoria: str | None = None
    foto_referencia: str | None = None


class HotelEditar(BaseModel):
    nombre: str | None = Field(default=None, min_length=1, max_length=150)
    direccion: str | None = Field(default=None, max_length=200)
    descripcion: str | None = None
    contacto: str | None = Field(default=None, max_length=50)
    categoria: str | None = Field(default=None, max_length=50)
    foto_referencia: str | None = Field(default=None, max_length=255)


class HabitacionPanelOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_habitacion: int
    id_hotel: int
    nombre: str
    descripcion: str | None = None
    tipo_cama: str | None = None
    capacidad: int
    precio: Decimal
    foto_referencia: str | None = None
    activa: bool


class HabitacionCrear(BaseModel):
    nombre: str = Field(min_length=1, max_length=150)
    descripcion: str | None = None
    tipo_cama: str | None = Field(default=None, max_length=60)
    capacidad: int = Field(ge=1, le=10)
    precio: Decimal = Field(gt=0)
    foto_referencia: str | None = Field(default=None, max_length=255)


class HabitacionEditar(BaseModel):
    nombre: str | None = Field(default=None, min_length=1, max_length=150)
    descripcion: str | None = None
    tipo_cama: str | None = Field(default=None, max_length=60)
    capacidad: int | None = Field(default=None, ge=1, le=10)
    precio: Decimal | None = Field(default=None, gt=0)
    foto_referencia: str | None = Field(default=None, max_length=255)
    activa: bool | None = None


class ReservaHotelOut(BaseModel):
    id_vp: int
    cliente: str
    correo_cliente: str
    fecha_inicial: date
    fecha_final: date
    num_personas: int
    precio: Decimal
    estado: str
    habitaciones: list[str]