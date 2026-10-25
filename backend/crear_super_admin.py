from getpass import getpass

from sqlalchemy import select

from app.core.database import SessionLocal
from app.core.security import encriptar_contrasena
from app.models import Usuario

correo = input("Correo del super admin: ").strip().lower()
nombre = input("Nombre: ").strip()
contrasena = getpass("Contraseña (mínimo 8 caracteres): ")

if len(contrasena) < 8:
    raise SystemExit("La contraseña es muy corta.")

with SessionLocal() as db:
    if db.scalar(select(Usuario).where(Usuario.correo == correo)):
        raise SystemExit("Ya existe un usuario con ese correo.")
    db.add(Usuario(
        nombre=nombre, correo=correo, rol="super_admin",
        password_hash=encriptar_contrasena(contrasena),
    ))
    db.commit()
    print("Super administrador creado.")