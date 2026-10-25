from collections import Counter
from decimal import Decimal

from fastapi import HTTPException
from psycopg2.extras import DateRange
from sqlalchemy import select, text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models import HabitacionTabla, HotelTabla, Usuario, Viaje, ViajeHabitacion
from app.schemas.viaje import (
    HabitacionSugerida, HabitacionViajeOut, SugerenciaOut, SugerirPeticion,
    ViajeCrear, ViajeOut,
)


def _ocupadas(db: Session, ini, fin) -> set[int]:
    filas = db.execute(
        text("""
            SELECT DISTINCT id_habitacion FROM viaje_habitacion
            WHERE activa AND fechas && daterange(:ini, :fin, '[)')
        """),
        {"ini": ini, "fin": fin},
    )
    return {f[0] for f in filas}


def finalizar_vencidos(db: Session) -> None:
    """Marca como finalizados los viajes cuya fecha de salida ya pasó.
    El trigger trg_sync_habitaciones libera sus habitaciones."""
    db.execute(text("""
        UPDATE viaje_personalizado
        SET estado = 'finalizado'
        WHERE estado = 'reservado' AND fecha_final < CURRENT_DATE
    """))
    db.commit()


def _a_salida(viaje: Viaje) -> ViajeOut:
    return ViajeOut(
        id_vp=viaje.id_vp,
        id_destino=viaje.id_destino,
        nombre_destino=viaje.destino.nombre,
        id_hotel=viaje.id_hotel,
        nombre_hotel=viaje.hotel.nombre,
        fecha_inicial=viaje.fecha_inicial,
        fecha_final=viaje.fecha_final,
        noches=(viaje.fecha_final - viaje.fecha_inicial).days,
        num_personas=viaje.num_personas,
        precio=viaje.precio,
        estado=viaje.estado,
        habitaciones=[
            HabitacionViajeOut(
                id_habitacion=vh.id_habitacion,
                nombre_habitacion=vh.habitacion.nombre,
                personas_asignadas=vh.personas_asignadas,
                precio_noche=vh.precio_noche,
            )
            for vh in viaje.habitaciones
        ],
    )


def crear_viaje(db: Session, usuario: Usuario, datos: ViajeCrear) -> ViajeOut:
    hotel = db.get(HotelTabla, datos.id_hotel)
    if not hotel or not hotel.activo:
        raise HTTPException(404, "Hotel no encontrado")

    ids = [h.id_habitacion for h in datos.habitaciones]
    if any(n > 1 for n in Counter(ids).values()):
        raise HTTPException(400, "No puedes elegir la misma habitación dos veces")

    habitaciones = {
        h.id_habitacion: h
        for h in db.scalars(
            select(HabitacionTabla).where(HabitacionTabla.id_habitacion.in_(ids))
        )
    }

    suma = 0
    for pedida in datos.habitaciones:
        hab = habitaciones.get(pedida.id_habitacion)
        if not hab or not hab.activa or hab.id_hotel != hotel.id_hotel:
            raise HTTPException(400, f"La habitación {pedida.id_habitacion} no pertenece a este hotel")
        if pedida.personas > hab.capacidad:
            raise HTTPException(
                400, f"'{hab.nombre}' admite máximo {hab.capacidad} personas, pediste {pedida.personas}"
            )
        suma += pedida.personas

    if suma != datos.num_personas:
        raise HTTPException(
            400,
            f"Viajan {datos.num_personas} personas pero asignaste {suma}. "
            "La suma debe coincidir con el total del grupo.",
        )

    noches = (datos.fecha_final - datos.fecha_inicial).days
    total = sum((habitaciones[h.id_habitacion].precio * noches for h in datos.habitaciones), Decimal(0))

    viaje = Viaje(
        id_usuario=usuario.id_usuario,
        id_destino=hotel.id_destino,
        id_hotel=hotel.id_hotel,
        fecha_inicial=datos.fecha_inicial,
        fecha_final=datos.fecha_final,
        num_personas=datos.num_personas,
        precio=total,
        estado="reservado",
    )
    rango = DateRange(datos.fecha_inicial, datos.fecha_final, "[)")
    for pedida in datos.habitaciones:
        hab = habitaciones[pedida.id_habitacion]
        viaje.habitaciones.append(ViajeHabitacion(
            id_habitacion=hab.id_habitacion,
            personas_asignadas=pedida.personas,
            precio_noche=hab.precio,
            fechas=rango,
            activa=True,
        ))

    db.add(viaje)
    try:
        db.commit()  # la base rechaza cruces de fechas aunque dos personas reserven a la vez
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, "Alguna de las habitaciones ya fue reservada en esas fechas")
    db.refresh(viaje)
    return _a_salida(viaje)


def mis_viajes(db: Session, usuario: Usuario) -> list[ViajeOut]:
    finalizar_vencidos(db)
    viajes = db.scalars(
        select(Viaje).where(Viaje.id_usuario == usuario.id_usuario)
        .order_by(Viaje.fecha_inicial.desc())
    ).all()
    return [_a_salida(v) for v in viajes]


def cancelar_viaje(db: Session, usuario: Usuario, id_vp: int) -> ViajeOut:
    viaje = db.get(Viaje, id_vp)
    if not viaje or viaje.id_usuario != usuario.id_usuario:
        raise HTTPException(404, "Viaje no encontrado")
    if viaje.estado != "reservado":
        raise HTTPException(400, f"El viaje ya está {viaje.estado}")
    viaje.estado = "cancelado"  # el trigger libera las habitaciones
    db.commit()
    db.refresh(viaje)
    return _a_salida(viaje)


def sugerir(db: Session, datos: SugerirPeticion) -> SugerenciaOut:
    """Elige las habitaciones libres más baratas por persona hasta cubrir al grupo."""
    if datos.fecha_final <= datos.fecha_inicial:
        raise HTTPException(400, "La fecha de salida debe ser posterior a la de llegada")

    noches = (datos.fecha_final - datos.fecha_inicial).days
    ocupadas = _ocupadas(db, datos.fecha_inicial, datos.fecha_final)
    libres = [
        h for h in db.scalars(
            select(HabitacionTabla).where(
                HabitacionTabla.id_hotel == datos.id_hotel, HabitacionTabla.activa.is_(True)
            )
        )
        if h.id_habitacion not in ocupadas
    ]
    capacidad_total = sum(h.capacidad for h in libres)

    if capacidad_total < datos.num_personas:
        return SugerenciaOut(
            posible=False,
            mensaje=f"El hotel solo tiene cupo para {capacidad_total} personas en esas fechas.",
            capacidad_disponible=capacidad_total,
            habitaciones=[],
            total_estimado=Decimal(0),
        )

    # Primero las habitaciones con mejor precio por persona
    libres.sort(key=lambda h: (h.precio / h.capacidad, -h.capacidad))
    faltan = datos.num_personas
    elegidas: list[HabitacionSugerida] = []
    for hab in libres:
        if faltan <= 0:
            break
        personas = min(hab.capacidad, faltan)
        elegidas.append(HabitacionSugerida(
            id_habitacion=hab.id_habitacion, nombre=hab.nombre, capacidad=hab.capacidad,
            personas=personas, precio_noche=hab.precio,
        ))
        faltan -= personas

    total = sum((e.precio_noche * noches for e in elegidas), Decimal(0))
    return SugerenciaOut(
        posible=True,
        mensaje=f"{len(elegidas)} habitación(es) para {datos.num_personas} personas.",
        capacidad_disponible=capacidad_total,
        habitaciones=elegidas,
        total_estimado=total,
    )