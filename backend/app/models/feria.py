from datetime import date
from decimal import Decimal
from sqlalchemy import Boolean, Date, Enum, ForeignKey, Numeric, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Feria(Base):
    __tablename__ = "ferias"

    id_feria: Mapped[int] = mapped_column(primary_key=True)
    id_depto: Mapped[int | None] = mapped_column(ForeignKey("deptos.id_depto"))
    id_destino: Mapped[int | None] = mapped_column(ForeignKey("destinos.id_destino"))
    nombre: Mapped[str] = mapped_column(String(150))
    tipo: Mapped[str] = mapped_column(
        Enum("feria", "oferta", name="tipo_feria", create_type=False)
    )  # 'feria' | 'oferta'
    descripcion: Mapped[str | None] = mapped_column(Text)
    foto_referencia: Mapped[str | None] = mapped_column(String(255))
    fecha_inicio: Mapped[date | None] = mapped_column(Date)
    fecha_fin: Mapped[date | None] = mapped_column(Date)
    descuento_porcentaje: Mapped[Decimal | None] = mapped_column(Numeric(5, 2))
    activo: Mapped[bool] = mapped_column(Boolean, default=True)

    depto = relationship("Depto")
    destino = relationship("Destino")