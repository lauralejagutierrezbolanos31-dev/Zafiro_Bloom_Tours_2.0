from datetime import datetime
from sqlalchemy import Boolean, DateTime, Enum, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Usuario(Base):
    __tablename__ = "usuario"

    id_usuario: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(String(100))
    apellidos: Mapped[str | None] = mapped_column(String(100))
    ciudad: Mapped[str | None] = mapped_column(String(100))
    direccion: Mapped[str | None] = mapped_column(String(200))
    correo: Mapped[str] = mapped_column(String(150), unique=True)
    telefono: Mapped[str | None] = mapped_column(String(30))
    documento: Mapped[str | None] = mapped_column(String(30))
    rol: Mapped[str] = mapped_column(
        Enum("usuario", "admin_hotel", "super_admin", name="rol_usuario", create_type=False),
        default="usuario",
    )
    password_hash: Mapped[str] = mapped_column(String(255))
    activo: Mapped[bool] = mapped_column(Boolean, default=True)
    fecha_registro: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())