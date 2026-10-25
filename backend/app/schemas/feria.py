from datetime import date
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, Field, model_validator


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


class FeriaAdminOut(FeriaOut):
    id_depto: int | None = None
    id_destino: int | None = None
    activo: bool


class FeriaGuardar(BaseModel):
    """Se usa para crear y para editar (el formulario envía todos los campos)."""
    nombre: str = Field(min_length=1, max_length=150)
    tipo: Literal["feria", "oferta"]
    descripcion: str | None = None
    foto_referencia: str | None = Field(default=None, max_length=255)
    id_depto: int | None = None
    id_destino: int | None = None
    fecha_inicio: date | None = None
    fecha_fin: date | None = None
    descuento_porcentaje: Decimal | None = Field(default=None, ge=0, le=100)
    activo: bool = True

    @model_validator(mode="after")
    def validar(self):
        if self.fecha_inicio and self.fecha_fin and self.fecha_fin < self.fecha_inicio:
            raise ValueError("La fecha final no puede ser anterior a la inicial")
        if self.tipo == "oferta" and not self.descuento_porcentaje:
            raise ValueError("Una oferta necesita un porcentaje de descuento")
        if self.tipo == "feria":
            self.descuento_porcentaje = None
        return self