from datetime import datetime, timedelta, timezone

import bcrypt
import jwt

from app.core.config import settings

ALGORITMO = "HS256"


def encriptar_contrasena(contrasena: str) -> str:
    return bcrypt.hashpw(contrasena.encode(), bcrypt.gensalt()).decode()


def verificar_contrasena(contrasena: str, hash_guardado: str) -> bool:
    try:
        return bcrypt.checkpw(contrasena.encode(), hash_guardado.encode())
    except ValueError:
        return False


def crear_token(id_usuario: int, rol: str) -> str:
    vence = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    datos = {"sub": str(id_usuario), "rol": rol, "exp": vence}
    return jwt.encode(datos, settings.SECRET_KEY, algorithm=ALGORITMO)


def decodificar_token(token: str) -> dict:
    return jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITMO])