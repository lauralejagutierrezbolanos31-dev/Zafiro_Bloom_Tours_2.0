from pydantic import BaseModel, ConfigDict


class DeptoOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_depto: int
    nombre: str
    foto_referencia: str | None = None
    descripcion: str | None = None