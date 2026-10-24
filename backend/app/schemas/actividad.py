from pydantic import BaseModel, ConfigDict


class ActividadOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_actividades: int
    id_destino: int
    descripcion: str
    contacto: str | None = None
    foto_referencia: str | None = None