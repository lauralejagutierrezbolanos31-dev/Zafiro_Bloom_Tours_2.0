from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UsuarioRegistro(BaseModel):
    nombre: str = Field(min_length=1, max_length=100)
    apellidos: str | None = Field(default=None, max_length=100)
    ciudad: str | None = Field(default=None, max_length=100)
    direccion: str | None = Field(default=None, max_length=200)
    telefono: str | None = Field(default=None, max_length=30)
    correo: EmailStr
    contrasena: str = Field(min_length=8, max_length=72)


class UsuarioLogin(BaseModel):
    correo: EmailStr
    contrasena: str = Field(max_length=72)


class UsuarioEditar(BaseModel):
    nombre: str | None = Field(default=None, min_length=1, max_length=100)
    apellidos: str | None = Field(default=None, max_length=100)
    ciudad: str | None = Field(default=None, max_length=100)
    direccion: str | None = Field(default=None, max_length=200)
    telefono: str | None = Field(default=None, max_length=30)


class EliminarCuenta(BaseModel):
    contrasena: str = Field(max_length=72)


class UsuarioOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_usuario: int
    nombre: str
    apellidos: str | None = None
    ciudad: str | None = None
    direccion: str | None = None
    correo: str
    telefono: str | None = None
    rol: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    usuario: UsuarioOut