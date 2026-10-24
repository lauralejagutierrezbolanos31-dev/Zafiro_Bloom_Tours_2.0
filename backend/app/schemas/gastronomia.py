from pydantic import BaseModel, ConfigDict


class GastronomiaOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_gastronomia: int
    id_destino: int
    descripcion: str
    contacto: str | None = None
    foto_referencia: str | None = None