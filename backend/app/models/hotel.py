from decimal import Decimal
from sqlalchemy import String, Text, Numeric, Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Hotel(Base):
    """Lee la vista v_hotel (precio promedio y ocupación calculados)."""
    __tablename__ = "v_hotel"

    id_hotel: Mapped[int] = mapped_column(primary_key=True)
    id_destino: Mapped[int] = mapped_column(Integer)
    nombre: Mapped[str] = mapped_column(String(150))
    foto_referencia: Mapped[str | None] = mapped_column(String(255))
    direccion: Mapped[str | None] = mapped_column(String(200))
    descripcion: Mapped[str | None] = mapped_column(Text)
    contacto: Mapped[str | None] = mapped_column(String(50))
    categoria: Mapped[str | None] = mapped_column(String(50))
    total_habitaciones: Mapped[int] = mapped_column(Integer)
    habitaciones_ocupadas: Mapped[int] = mapped_column(Integer)
    precio_promedio: Mapped[Decimal] = mapped_column(Numeric)
    porcentaje_ocupacion: Mapped[Decimal] = mapped_column(Numeric)