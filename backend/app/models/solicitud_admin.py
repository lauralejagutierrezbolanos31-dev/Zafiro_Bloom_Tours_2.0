from datetime import datetime
from sqlalchemy import DateTime, Enum, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class SolicitudAdmin(Base):
    __tablename__ = "solicitud_admin"

    id_solicitud: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(100))
    apellidos: Mapped[str | None] = mapped_column(String(100))
    documento: Mapped[str] = mapped_column(String(30))
    cargo: Mapped[str] = mapped_column(String(60))
    correo: Mapped[str] = mapped_column(String(150))
    telefono: Mapped[str | None] = mapped_column(String(30))
    password_hash: Mapped[str] = mapped_column(String(255))
    nombre_hotel: Mapped[str] = mapped_column(String(150))
    direccion_hotel: Mapped[str] = mapped_column(String(200))
    contacto_hotel: Mapped[str] = mapped_column(String(50))
    categoria: Mapped[str] = mapped_column(String(50))
    descripcion: Mapped[str] = mapped_column(Text)
    politicas: Mapped[str] = mapped_column(Text)
    id_destino: Mapped[int | None] = mapped_column(ForeignKey("destinos.id_destino"))
    estado: Mapped[str] = mapped_column(
        Enum("pendiente", "aprobada", "rechazada", name="estado_solicitud", create_type=False),
        default="pendiente",
    )
    fecha_registro: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    fecha_resolucion: Mapped[datetime | None] = mapped_column(DateTime)