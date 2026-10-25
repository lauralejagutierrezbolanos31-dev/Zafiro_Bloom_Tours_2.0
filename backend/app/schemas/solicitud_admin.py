from pydantic import BaseModel, EmailStr, Field


class SolicitudCrear(BaseModel):
    nombre: str = Field(min_length=1, max_length=100)
    apellidos: str | None = Field(default=None, max_length=100)
    documento: str = Field(min_length=1, max_length=30)
    cargo: str = Field(max_length=60)
    correo: EmailStr
    telefono: str | None = Field(default=None, max_length=30)
    contrasena: str = Field(min_length=8, max_length=72)
    nombre_hotel: str = Field(min_length=1, max_length=150)
    direccion_hotel: str = Field(min_length=1, max_length=200)
    contacto_hotel: str = Field(min_length=1, max_length=50)
    categoria: str = Field(max_length=50)
    descripcion: str = Field(min_length=1)
    politicas: str = Field(min_length=1)
    id_destino: int | None = None


class SolicitudRespuesta(BaseModel):
    mensaje: str