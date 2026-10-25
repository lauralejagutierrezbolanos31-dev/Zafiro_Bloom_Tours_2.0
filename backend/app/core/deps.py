import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decodificar_token
from app.models import Usuario

bearer = HTTPBearer()


def usuario_actual(
    credenciales: HTTPAuthorizationCredentials = Depends(bearer),
    db: Session = Depends(get_db),
) -> Usuario:
    try:
        datos = decodificar_token(credenciales.credentials)
        id_usuario = int(datos["sub"])
    except (jwt.PyJWTError, KeyError, ValueError):
        raise HTTPException(401, "Sesión inválida o expirada")

    usuario = db.get(Usuario, id_usuario)
    if not usuario or not usuario.activo:
        raise HTTPException(401, "Sesión inválida o expirada")
    return usuario


def requiere_rol(*roles: str):
    def verificador(usuario: Usuario = Depends(usuario_actual)) -> Usuario:
        if usuario.rol not in roles:
            raise HTTPException(403, "No tienes permisos para esta acción")
        return usuario
    return verificador