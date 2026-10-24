from pydantic import BaseModel, ConfigDict


class DestinoOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_destino: int
    id_depto: int
    nombre: str
    foto_referencia: str | None = None
    clima: str | None = None
    generalidades: str | None = None