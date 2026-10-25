import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";

import CarruselSeccion from "../components/CarruselSeccion";
import { actividadService } from "../services/actividadService";
import { destinoService } from "../services/destinoService";
import { gastronomiaService } from "../services/gastronomiaService";
import { transporteService } from "../services/transporteService";
import type { Destino } from "../types/destino";
import type { Informacion } from "../types/informacion";
import { urlImagen } from "../utils/imagen";
import "./DetalleDestino.css";

function DetalleDestino() {
  const { idDestino } = useParams<{ idDestino: string }>();
  const navigate = useNavigate();

  const [destino, setDestino] = useState<Destino | null>(null);
  const [gastronomia, setGastronomia] = useState<Informacion[]>([]);
  const [actividades, setActividades] = useState<Informacion[]>([]);
  const [transporte, setTransporte] = useState<Informacion[]>([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!idDestino) return;
    setCargando(true);
    Promise.all([
      destinoService.obtener(idDestino),
      gastronomiaService.listar(idDestino),
      actividadService.listar(idDestino),
      transporteService.listar(idDestino),
    ])
      .then(([d, g, a, t]) => {
        setDestino(d);
        setGastronomia(g);
        setActividades(a);
        setTransporte(t);
      })
      .catch(() => setError("No se pudo cargar el destino."))
      .finally(() => setCargando(false));
  }, [idDestino]);

  if (cargando) return <p className="mensaje-carga">Cargando...</p>;
  if (error || !destino) return <p className="mensaje-error">{error || "Destino no encontrado"}</p>;

  return (
    <>
      <div
        className="destino-banner"
        style={{ backgroundImage: `url("${urlImagen(destino.foto_referencia)}")` }}
      >
        <h1>{destino.nombre}</h1>
      </div>

      <section className="destino-info">
        {destino.clima && (
          <p className="destino-clima">
            <strong>Clima:</strong> {destino.clima}
          </p>
        )}
        {destino.generalidades && <p className="destino-generalidades">{destino.generalidades}</p>}
      </section>

      <div className="destino-acciones">
        <button
          className="boton boton-grande"
          type="button"
          onClick={() => navigate(`/crear-viaje/${destino.id_destino}`)}
        >
          Planear viaje aquí
        </button>
      </div>

      <CarruselSeccion titulo="Gastronomía típica" items={gastronomia} />
      <CarruselSeccion titulo="Actividades" items={actividades} />
      <CarruselSeccion titulo="Transporte" items={transporte} />
    </>
  );
}

export default DetalleDestino;