from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import encriptar_contrasena
from app.models import SolicitudAdmin, Usuario
from app.schemas.solicitud_admin import SolicitudCrear, SolicitudRespuesta

router = APIRouter(prefix="/solicitudes", tags=["Solicitudes de administrador"])


@router.post("/", response_model=SolicitudRespuesta, status_code=201)
def enviar_solicitud(datos: SolicitudCrear, db: Session = Depends(get_db)):
    correo = datos.correo.lower()
    if db.scalar(select(Usuario).where(Usuario.correo == correo)):
        raise HTTPException(409, "Ya existe una cuenta con ese correo")
    pendiente = db.scalar(
        select(SolicitudAdmin).where(
            SolicitudAdmin.correo == correo, SolicitudAdmin.estado == "pendiente"
        )
    )
    if pendiente:
        raise HTTPException(409, "Ya tienes una solicitud pendiente de revisión")

    campos = datos.model_dump(exclude={"contrasena", "correo"})
    db.add(SolicitudAdmin(**campos, correo=correo, password_hash=encriptar_contrasena(datos.contrasena)))
    db.commit()
    return SolicitudRespuesta(mensaje="Solicitud enviada. El Super Administrador la revisará.")