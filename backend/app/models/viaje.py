from datetime import date, datetime
from decimal import Decimal
from sqlalchemy import Boolean, Date, DateTime, Enum, ForeignKey, Integer, Numeric, func
from sqlalchemy.dialects.postgresql import DATERANGE
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Viaje(Base):
    __tablename__ = "viaje_personalizado"

    id_vp: Mapped[int] = mapped_column(primary_key=True)
    id_usuario: Mapped[int] = mapped_column(ForeignKey("usuario.id_usuario"))
    id_destino: Mapped[int] = mapped_column(ForeignKey("destinos.id_destino"))
    id_hotel: Mapped[int] = mapped_column(ForeignKey("hotel.id_hotel"))
    fecha_inicial: Mapped[date] = mapped_column(Date)
    fecha_final: Mapped[date] = mapped_column(Date)
    num_personas: Mapped[int] = mapped_column(Integer)
    precio: Mapped[Decimal] = mapped_column(Numeric(14, 2), default=0)
    estado: Mapped[str] = mapped_column(
        Enum("reservado", "cancelado", "finalizado", name="estado_viaje", create_type=False),
        default="reservado",
    )
    fecha_registro: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

    habitaciones: Mapped[list["ViajeHabitacion"]] = relationship(
        back_populates="viaje", cascade="all, delete-orphan"
    )
    hotel = relationship("HotelTabla")
    destino = relationship("Destino")


class ViajeHabitacion(Base):
    __tablename__ = "viaje_habitacion"

    id_vh: Mapped[int] = mapped_column(primary_key=True)
    id_vp: Mapped[int] = mapped_column(ForeignKey("viaje_personalizado.id_vp"))
    id_habitacion: Mapped[int] = mapped_column(ForeignKey("habitacion.id_habitacion"))
    personas_asignadas: Mapped[int] = mapped_column(Integer)
    precio_noche: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    fechas = mapped_column(DATERANGE)
    activa: Mapped[bool] = mapped_column(Boolean, default=True)

    viaje: Mapped["Viaje"] = relationship(back_populates="habitaciones")
    habitacion = relationship("HabitacionTabla")