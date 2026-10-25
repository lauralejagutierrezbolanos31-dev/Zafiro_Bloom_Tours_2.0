from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.routers import (
    deptos, destinos, gastronomia, actividades, transporte,
    ferias, hoteles, habitaciones, buscar, usuarios, viajes, solicitudes,
)
app = FastAPI(title="Zafiro Bloom Tours API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.FRONTEND_URL],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(deptos.router)
app.include_router(destinos.router)
app.include_router(gastronomia.router)
app.include_router(actividades.router)
app.include_router(transporte.router)
app.include_router(ferias.router)
app.include_router(hoteles.router)
app.include_router(habitaciones.router)
app.include_router(buscar.router)
app.include_router(usuarios.router)
app.include_router(viajes.router)
app.include_router(solicitudes.router)


@app.get("/", tags=["Estado"])
def raiz():
    return {"mensaje": "Zafiro Bloom Tours API funcionando"}


@app.get("/salud", tags=["Estado"])
def salud(db: Session = Depends(get_db)):
    total = db.execute(text("SELECT COUNT(*) FROM deptos")).scalar()
    return {"base_de_datos": "conectada", "departamentos": total}