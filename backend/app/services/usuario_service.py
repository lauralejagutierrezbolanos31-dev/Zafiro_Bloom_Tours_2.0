from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import encriptar_contrasena, verificar_contrasena
from app.models import Usuario
from app.schemas.usuario import UsuarioRegistro


def registrar(db: Session, datos: UsuarioRegistro) -> Usuario:
    correo = datos.correo.lower()
    if db.scalar(select(Usuario).where(Usuario.correo == correo)):
        raise HTTPException(409, "Ya existe una cuenta con ese correo")

    usuario = Usuario(
        nombre=datos.nombre,
        apellidos=datos.apellidos,
        ciudad=datos.ciudad,
        direccion=datos.direccion,
        telefono=datos.telefono,
        correo=correo,
        rol="usuario",
        password_hash=encriptar_contrasena(datos.contrasena),
    )
    db.add(usuario)
    db.commit()
    db.refresh(usuario)
    return usuario


def autenticar(db: Session, correo: str, contrasena: str) -> Usuario:
    usuario = db.scalar(select(Usuario).where(Usuario.correo == correo.lower()))
    # Mismo mensaje en ambos casos para no revelar si el correo existe
    if not usuario or not usuario.activo or not verificar_contrasena(contrasena, usuario.password_hash):
        raise HTTPException(401, "Correo o contraseña incorrectos")
    return usuario