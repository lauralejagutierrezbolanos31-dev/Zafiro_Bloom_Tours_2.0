from datetime import datetime

from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import HotelTabla, SolicitudAdmin, Usuario


def listar(db: Session, estado: str | None) -> list[SolicitudAdmin]:
    consulta = select(SolicitudAdmin).order_by(SolicitudAdmin.fecha_registro.desc())
    if estado:
        consulta = consulta.where(SolicitudAdmin.estado == estado)
    return list(db.scalars(consulta))


def _pendiente(db: Session, id_solicitud: int) -> SolicitudAdmin:
    solicitud = db.get(SolicitudAdmin, id_solicitud)
    if not solicitud:
        raise HTTPException(404, "Solicitud no encontrada")
    if solicitud.estado != "pendiente":
        raise HTTPException(400, f"La solicitud ya fue {solicitud.estado}")
    return solicitud


def aprobar(
    db: Session, id_solicitud: int, id_destino: int | None, admin: Usuario
) -> SolicitudAdmin:
    solicitud = _pendiente(db, id_solicitud)

    destino = id_destino or solicitud.id_destino
    if not destino:
        raise HTTPException(400, "Debes asignar un destino antes de aprobar")

    if db.scalar(select(Usuario).where(Usuario.correo == solicitud.correo)):
        raise HTTPException(409, "Ya existe un usuario con ese correo")

    usuario = Usuario(
        nombre=solicitud.nombre,
        apellidos=solicitud.apellidos,
        correo=solicitud.correo,
        telefono=solicitud.telefono,
        documento=solicitud.documento,
        rol="admin_hotel",
        password_hash=solicitud.password_hash,
    )
    db.add(usuario)
    db.flush()  # genera id_usuario

    db.add(HotelTabla(
        id_destino=destino,
        id_propietario=usuario.id_usuario,
        id_solicitud=solicitud.id_solicitud,
        nombre=solicitud.nombre_hotel,
        direccion=solicitud.direccion_hotel,
        descripcion=solicitud.descripcion,
        contacto=solicitud.contacto_hotel,
        categoria=solicitud.categoria,
        politicas=solicitud.politicas,
    ))

    solicitud.estado = "aprobada"
    solicitud.id_destino = destino
    solicitud.fecha_resolucion = datetime.now()
    solicitud.resuelta_por = admin.id_usuario
    db.commit()
    db.refresh(solicitud)
    return solicitud


def rechazar(
    db: Session, id_solicitud: int, admin: Usuario, motivo: str | None
) -> SolicitudAdmin:
    solicitud = _pendiente(db, id_solicitud)
    solicitud.estado = "rechazada"
    solicitud.fecha_resolucion = datetime.now()
    solicitud.resuelta_por = admin.id_usuario
    solicitud.motivo_rechazo = motivo
    db.commit()
    db.refresh(solicitud)
    return solicitud