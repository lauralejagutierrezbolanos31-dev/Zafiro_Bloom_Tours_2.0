from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import HabitacionTabla, HotelTabla, Usuario, Viaje, ViajeHabitacion
from app.schemas.panel import (
    HabitacionCrear, HabitacionEditar, HotelEditar, ReservaHotelOut,
)


def mis_hoteles(db: Session, usuario: Usuario) -> list[HotelTabla]:
    consulta = select(HotelTabla).where(HotelTabla.activo.is_(True)).order_by(HotelTabla.nombre)
    if usuario.rol != "super_admin":
        consulta = consulta.where(HotelTabla.id_propietario == usuario.id_usuario)
    return list(db.scalars(consulta))


def hotel_propio(db: Session, usuario: Usuario, id_hotel: int) -> HotelTabla:
    hotel = db.get(HotelTabla, id_hotel)
    if not hotel or not hotel.activo:
        raise HTTPException(404, "Hotel no encontrado")
    if usuario.rol != "super_admin" and hotel.id_propietario != usuario.id_usuario:
        raise HTTPException(403, "Este hotel no te pertenece")
    return hotel


def editar_hotel(db: Session, usuario: Usuario, id_hotel: int, datos: HotelEditar) -> HotelTabla:
    hotel = hotel_propio(db, usuario, id_hotel)
    for campo, valor in datos.model_dump(exclude_unset=True).items():
        setattr(hotel, campo, valor)
    db.commit()
    db.refresh(hotel)
    return hotel


def habitaciones_de(db: Session, usuario: Usuario, id_hotel: int) -> list[HabitacionTabla]:
    hotel_propio(db, usuario, id_hotel)
    return list(db.scalars(
        select(HabitacionTabla).where(HabitacionTabla.id_hotel == id_hotel)
        .order_by(HabitacionTabla.id_habitacion)
    ))


def crear_habitacion(db: Session, usuario: Usuario, id_hotel: int, datos: HabitacionCrear) -> HabitacionTabla:
    hotel_propio(db, usuario, id_hotel)
    habitacion = HabitacionTabla(id_hotel=id_hotel, **datos.model_dump())
    db.add(habitacion)
    db.commit()
    db.refresh(habitacion)
    return habitacion


def _habitacion_propia(db: Session, usuario: Usuario, id_habitacion: int) -> HabitacionTabla:
    habitacion = db.get(HabitacionTabla, id_habitacion)
    if not habitacion:
        raise HTTPException(404, "Habitación no encontrada")
    hotel_propio(db, usuario, habitacion.id_hotel)
    return habitacion


def editar_habitacion(db: Session, usuario: Usuario, id_habitacion: int, datos: HabitacionEditar) -> HabitacionTabla:
    habitacion = _habitacion_propia(db, usuario, id_habitacion)
    for campo, valor in datos.model_dump(exclude_unset=True).items():
        setattr(habitacion, campo, valor)
    db.commit()
    db.refresh(habitacion)
    return habitacion


def desactivar_habitacion(db: Session, usuario: Usuario, id_habitacion: int) -> None:
    habitacion = _habitacion_propia(db, usuario, id_habitacion)
    reservada = db.scalar(
        select(ViajeHabitacion.id_vh).where(
            ViajeHabitacion.id_habitacion == id_habitacion, ViajeHabitacion.activa.is_(True)
        ).limit(1)
    )
    if reservada:
        raise HTTPException(409, "Esta habitación tiene reservas activas; no se puede quitar")
    habitacion.activa = False  # se desactiva para conservar el historial
    db.commit()


def reservas_del_hotel(db: Session, usuario: Usuario, id_hotel: int) -> list[ReservaHotelOut]:
    hotel_propio(db, usuario, id_hotel)
    viajes = db.scalars(
        select(Viaje).where(Viaje.id_hotel == id_hotel).order_by(Viaje.fecha_inicial.desc())
    ).all()
    salida = []
    for v in viajes:
        cliente = db.get(Usuario, v.id_usuario)
        salida.append(ReservaHotelOut(
            id_vp=v.id_vp,
            cliente=f"{cliente.nombre} {cliente.apellidos or ''}".strip(),
            correo_cliente=cliente.correo,
            fecha_inicial=v.fecha_inicial,
            fecha_final=v.fecha_final,
            num_personas=v.num_personas,
            precio=v.precio,
            estado=v.estado,
            habitaciones=[f"{vh.habitacion.nombre} ({vh.personas_asignadas})" for vh in v.habitaciones],
        ))
    return salida