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
    foto_referencia: Mapped[str | None] = mapped_column(String(255))
    direccion: Mapped[str | None] = mapped_column(String(200))
    descripcion: Mapped[str | None] = mapped_column(Text)
    contacto: Mapped[str | None] = mapped_column(String(50))
    categoria: Mapped[str | None] = mapped_column(String(50))
    politicas: Mapped[str | None] = mapped_column(Text)
    activo: Mapped[bool] = mapped_column(Boolean, default=True)


class HabitacionTabla(Base):
    __tablename__ = "habitacion"

    id_habitacion: Mapped[int] = mapped_column(primary_key=True)
    id_hotel: Mapped[int] = mapped_column(ForeignKey("hotel.id_hotel"))
    nombre: Mapped[str] = mapped_column(String(150))
    descripcion: Mapped[str | None] = mapped_column(Text)
    tipo_cama: Mapped[str | None] = mapped_column(String(60))
    capacidad: Mapped[int] = mapped_column(Integer)
    precio: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    foto_referencia: Mapped[str | None] = mapped_column(String(255))
    activa: Mapped[bool] = mapped_column(Boolean, default=True)