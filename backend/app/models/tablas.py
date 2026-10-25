from decimal import Decimal
from sqlalchemy import Boolean, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class HotelTabla(Base):
    __tablename__ = "hotel"

    id_hotel: Mapped[int] = mapped_column(primary_key=True)
    id_destino: Mapped[int] = mapped_column(ForeignKey("destinos.id_destino"))
    id_propietario: Mapped[int | None] = mapped_column(ForeignKey("usuario.id_usuario"))
    nombre: Mapped[str] = mapped_column(String(150))
    activo: Mapped[bool] = mapped_column(Boolean, default=True)


class HabitacionTabla(Base):
    __tablename__ = "habitacion"

    id_habitacion: Mapped[int] = mapped_column(primary_key=True)
    id_hotel: Mapped[int] = mapped_column(ForeignKey("hotel.id_hotel"))
    nombre: Mapped[str] = mapped_column(String(150))
    capacidad: Mapped[int] = mapped_column(Integer)
    precio: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    activa: Mapped[bool] = mapped_column(Boolean, default=True)