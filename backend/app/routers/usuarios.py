from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import usuario_actual
from app.core.security import crear_token, verificar_contrasena
from app.models import Usuario
from app.schemas.usuario import (
    EliminarCuenta, TokenOut, UsuarioEditar, UsuarioLogin, UsuarioOut, UsuarioRegistro,
)
from app.services import usuario_service

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


@router.post("/registro", response_model=TokenOut, status_code=201)
def registro(datos: UsuarioRegistro, db: Session = Depends(get_db)):
    usuario = usuario_service.registrar(db, datos)
    return TokenOut(access_token=crear_token(usuario.id_usuario, usuario.rol), usuario=usuario)


@router.post("/login", response_model=TokenOut)
def login(datos: UsuarioLogin, db: Session = Depends(get_db)):
    usuario = usuario_service.autenticar(db, datos.correo, datos.contrasena)
    return TokenOut(access_token=crear_token(usuario.id_usuario, usuario.rol), usuario=usuario)


@router.get("/me", response_model=UsuarioOut)
def mi_perfil(usuario: Usuario = Depends(usuario_actual)):
    return usuario


@router.put("/me", response_model=UsuarioOut)
def editar_perfil(
    datos: UsuarioEditar,
    usuario: Usuario = Depends(usuario_actual),
    db: Session = Depends(get_db),
):
    for campo, valor in datos.model_dump(exclude_unset=True).items():
        setattr(usuario, campo, valor)
    db.commit()
    db.refresh(usuario)
    return usuario


@router.delete("/me", status_code=204)
def eliminar_cuenta(
    datos: EliminarCuenta,
    usuario: Usuario = Depends(usuario_actual),
    db: Session = Depends(get_db),
):
    if not verificar_contrasena(datos.contrasena, usuario.password_hash):
        raise HTTPException(401, "Contraseña incorrecta")
    usuario.activo = False  # se desactiva, no se borra: conserva el historial de viajes
    db.commit()