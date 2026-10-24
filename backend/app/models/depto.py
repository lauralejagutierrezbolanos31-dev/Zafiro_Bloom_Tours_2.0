from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Depto(Base):
    __tablename__ = "deptos"

    id_depto: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(100), unique=True)
    foto_referencia: Mapped[str | None] = mapped_column(String(255))
    descripcion: Mapped[str | None] = mapped_column(Text)