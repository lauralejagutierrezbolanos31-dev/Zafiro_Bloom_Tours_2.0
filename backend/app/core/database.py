from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, DeclarativeBase

from app.core.config import settings


def _motivo(e: Exception) -> str:
    # Postgres en Windows a veces responde en español (cp1252) y psycopg2 no puede leerlo
    if isinstance(e, UnicodeDecodeError):
        return e.object.decode("cp1252", errors="replace")
    return str(e).splitlines()[0] if str(e) else type(e).__name__


def _crear_engine():
    urls = [u for u in (settings.DATABASE_URL, settings.DATABASE_URL_RESPALDO) if u]
    for url in urls:
        local = "localhost" in url or "127.0.0.1" in url
        nombre = "Postgres local" if local else "Neon (nube)"
        try:
            motor = create_engine(url, pool_pre_ping=True, connect_args={"connect_timeout": 6})
            with motor.connect() as conexion:
                conexion.execute(text("SELECT 1"))
            print(f"[BD] Conectado a: {nombre}")
            return motor
        except Exception as e:
            print(f"[BD] Falló {nombre}: {_motivo(e)}")
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