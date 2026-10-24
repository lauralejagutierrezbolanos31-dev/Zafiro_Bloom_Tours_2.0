from sqlalchemy import ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Transporte(Base):
    __tablename__ = "transporte"

    id_transporte: Mapped[int] = mapped_column(primary_key=True)
    id_destino: Mapped[int] = mapped_column(ForeignKey("destinos.id_destino"))
    descripcion: Mapped[str] = mapped_column(Text)
    contacto: Mapped[str | None] = mapped_column(String(30))
    foto_referencia: Mapped[str | None] = mapped_column(String(255))