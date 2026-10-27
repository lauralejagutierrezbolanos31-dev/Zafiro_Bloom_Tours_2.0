from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, DeclarativeBase

from app.core.config import settings


def _crear_engine():
    urls = [u for u in (settings.DATABASE_URL, settings.DATABASE_URL_RESPALDO) if u]
    for url in urls:
        try:
            motor = create_engine(url, pool_pre_ping=True, connect_args={"connect_timeout": 4})
            with motor.connect() as conexion:
                conexion.execute(text("SELECT 1"))
            local = "localhost" in url or "127.0.0.1" in url
            print(f"[BD] Conectado a: {'Postgres local' if local else 'Neon (nube)'}")
            return motor
        except Exception:
            print("[BD] No se pudo conectar a una base, probando la siguiente...")
    raise RuntimeError("No hay ninguna base disponible. Revisa DATABASE_URL en backend/.env")


engine = _crear_engine()
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()