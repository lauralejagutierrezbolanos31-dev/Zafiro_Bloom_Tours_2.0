from pydantic import BaseModel

from app.schemas.depto import DeptoOut
from app.schemas.destino import DestinoOut


class ResultadoBusqueda(BaseModel):
    departamentos: list[DeptoOut]
    destinos: list[DestinoOut]