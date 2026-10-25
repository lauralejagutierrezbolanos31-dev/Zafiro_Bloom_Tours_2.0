from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Depto, Destino, Feria
from app.schemas.feria import FeriaAdminOut, FeriaGuardar


def _a_salida(f: Feria) -> FeriaAdminOut:
    return FeriaAdminOut(
        id_feria=f.id_feria,
        nombre=f.nombre,
        tipo=f.tipo,
        descripcion=f.descripcion,
        foto_referencia=f.foto_referencia,
        fecha_inicio=f.fecha_inicio,
        fecha_fin=f.fecha_fin,
        descuento_porcentaje=f.descuento_porcentaje,
        nombre_depto=f.depto.nombre if f.depto else None,
        nombre_destino=f.destino.nombre if f.destino else None,
        id_depto=f.id_depto,
        id_destino=f.id_destino,
        activo=f.activo,
    )


def _validar_ubicacion(db: Session, datos: FeriaGuardar) -> None:
    if datos.id_depto and not db.get(Depto, datos.id_depto):
        raise HTTPException(404, "El departamento no existe")
    if datos.id_destino:
        destino = db.get(Destino, datos.id_destino)
        if not destino:
            raise HTTPException(404, "El destino no existe")
        if datos.id_depto and destino.id_depto != datos.id_depto:
            raise HTTPException(400, "El destino no pertenece a ese departamento")


def _obtener(db: Session, id_feria: int) -> Feria:
    feria = db.get(Feria, id_feria)
    if not feria:
        raise HTTPException(404, "Feria u oferta no encontrada")
    return feria


def listar(db: Session, tipo: str | None) -> list[FeriaAdminOut]:
    consulta = select(Feria).order_by(Feria.fecha_inicio.desc())
    if tipo in ("feria", "oferta"):
        consulta = consulta.where(Feria.tipo == tipo)
    return [_a_salida(f) for f in db.scalars(consulta)]


def crear(db: Session, datos: FeriaGuardar) -> FeriaAdminOut:
    _validar_ubicacion(db, datos)
    feria = Feria(**datos.model_dump())
    db.add(feria)
    db.commit()
    db.refresh(feria)
    return _a_salida(feria)


def actualizar(db: Session, id_feria: int, datos: FeriaGuardar) -> FeriaAdminOut:
    feria = _obtener(db, id_feria)
    _validar_ubicacion(db, datos)
    for campo, valor in datos.model_dump().items():
        setattr(feria, campo, valor)
    db.commit()
    db.refresh(feria)
    return _a_salida(feria)


def eliminar(db: Session, id_feria: int) -> None:
    db.delete(_obtener(db, id_feria))
    db.commit()