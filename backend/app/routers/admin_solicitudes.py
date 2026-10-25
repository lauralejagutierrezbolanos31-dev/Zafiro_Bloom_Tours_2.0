from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import requiere_rol
from app.models import Usuario
from app.schemas.panel import RechazarSolicitud, ResolverSolicitud, SolicitudAdminOut
from app.services import solicitud_service

router = APIRouter(prefix="/admin/solicitudes", tags=["Panel Super Administrador"])

solo_super = requiere_rol("super_admin")


@router.get("/", response_model=list[SolicitudAdminOut])
def listar(estado: str | None = None, _: Usuario = Depends(solo_super), db: Session = Depends(get_db)):
    return solicitud_service.listar(db, estado)


@router.put("/{id_solicitud}/aprobar", response_model=SolicitudAdminOut)
def aprobar(
    id_solicitud: int, datos: ResolverSolicitud,
    admin: Usuario = Depends(solo_super), db: Session = Depends(get_db),
):
    return solicitud_service.aprobar(db, id_solicitud, datos.id_destino, admin)


@router.put("/{id_solicitud}/rechazar", response_model=SolicitudAdminOut)
def rechazar(
    id_solicitud: int, datos: RechazarSolicitud | None = None,
    admin: Usuario = Depends(solo_super), db: Session = Depends(get_db),
):
    return solicitud_service.rechazar(db, id_solicitud, admin, datos.motivo if datos else None)