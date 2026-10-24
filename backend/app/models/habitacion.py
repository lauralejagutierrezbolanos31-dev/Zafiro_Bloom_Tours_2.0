from decimal import Decimal
from sqlalchemy import String, Text, Numeric, Boolean, Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Habitacion(Base):
    """Lee la vista v_habitacion."""
    __tablename__ = "v_habitacion"

    id_habitacion: Mapped[int] = mapped_column(primary_key=True)
    id_hotel: Mapped[int] = mapped_column(Integer)
    nombre: Mapped[str] = mapped_column(String(150))
    descripcion: Mapped[str | None] = mapped_column(Text)
    tipo_cama: Mapped[str | None] = mapped_column(String(60))
    capacidad: Mapped[int] = mapped_column(Integer)
    precio: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    foto_referencia: Mapped[str | None] = mapped_column(String(255))
    activa: Mapped[bool] = mapped_column(Boolean)
    ocupada: Mapped[bool] = mapped_column(Boolean)