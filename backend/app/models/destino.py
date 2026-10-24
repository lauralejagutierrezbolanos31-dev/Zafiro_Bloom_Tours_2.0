from datetime import datetime
from sqlalchemy import ForeignKey, String, Text, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Destino(Base):
    __tablename__ = "destinos"

    id_destino: Mapped[int] = mapped_column(primary_key=True)
    id_depto: Mapped[int] = mapped_column(ForeignKey("deptos.id_depto"))
    nombre: Mapped[str] = mapped_column(String(150))
    foto_referencia: Mapped[str | None] = mapped_column(String(255))
    clima: Mapped[str | None] = mapped_column(Text)
    generalidades: Mapped[str | None] = mapped_column(Text)
    fecha_registro: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())