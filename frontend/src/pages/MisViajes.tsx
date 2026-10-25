import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";

import EncabezadoPagina from "../components/EncabezadoPagina";
import { useAuth } from "../context/AuthContext";
import { viajeService } from "../services/viajeService";
import type { Viaje } from "../types/viaje";
import { mensajeError } from "../utils/errores";
import { fechaCorta, hoy, moneda } from "../utils/formato";
import "./MisViajes.css";

type Filtro = "proximos" | "pasados" | "cancelados";

const ETIQUETAS: Record<Filtro, string> = {
  proximos: "Próximos",
  pasados: "Pasados",
  cancelados: "Cancelados",
};

function clasificar(v: Viaje): Filtro {
  if (v.estado === "cancelado") return "cancelados";
  if (v.estado === "finalizado" || v.fecha_final < hoy()) return "pasados";
  return "proximos";
}

function MisViajes() {
  const { usuario, abrirAuth } = useAuth();
  const [viajes, setViajes] = useState<Viaje[]>([]);
  const [filtro, setFiltro] = useState<Filtro>("proximos");
  const [cargando, setCargando] = useState(true);
  const [cancelando, setCancelando] = useState<number | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!usuario) {
      setCargando(false);
      return;
    }
    viajeService
      .misViajes()
      .then(setViajes)
      .catch(() => setError("No se pudieron cargar tus viajes."))
      .finally(() => setCargando(false));
  }, [usuario]);

  const conteo = useMemo(() => {
    const c: Record<Filtro, number> = { proximos: 0, pasados: 0, cancelados: 0 };
    viajes.forEach((v) => (c[clasificar(v)] += 1));
    return c;
  }, [viajes]);

  const visibles = viajes.filter((v) => clasificar(v) === filtro);

  async function cancelar(id: number) {
    if (cancelando !== null) return;
    if (!window.confirm("¿Seguro que quieres cancelar esta reserva?")) return;
    setCancelando(id);
    setError("");
    try {
      const actualizado = await viajeService.cancelar(id);
      setViajes((lista) => lista.map((v) => (v.id_vp === id ? actualizado : v)));
    } catch (err) {
      setError(mensajeError(err, "No se pudo cancelar la reserva."));
    } finally {
      setCancelando(null);
    }
  }

  if (!usuario) {
    return (
      <div className="viajes">
        <EncabezadoPagina titulo="Mis viajes" />
        <div className="viajes-vacio">
          <span>🔒</span>
          <p>Inicia sesión para ver tus reservas.</p>
          <button className="boton" onClick={abrirAuth}>Iniciar sesión</button>
        </div>
      </div>
    );
  }

  return (
    <div className="viajes">
      <EncabezadoPagina
        titulo="Mis viajes"
        subtitulo={`Hola, ${usuario.nombre}. Aquí están todas tus reservas.`}
      />

      <div className="viajes-pestanas">
        {(Object.keys(ETIQUETAS) as Filtro[]).map((f) => (
          <button
            key={f}
            className={filtro === f ? "activa" : ""}
            onClick={() => setFiltro(f)}
          >
            {ETIQUETAS[f]} <span>{conteo[f]}</span>
          </button>
        ))}
      </div>

      {cargando && <p className="mensaje-carga">Cargando tus viajes...</p>}
      {error && <p className="mensaje-error">{error}</p>}

      {!cargando && visibles.length === 0 && (
        <div className="viajes-vacio">
          <span>🧳</span>
          <p>
            {filtro === "proximos"
              ? "No tienes viajes próximos. ¿A dónde quieres ir?"
              : `No tienes viajes ${ETIQUETAS[filtro].toLowerCase()}.`}
          </p>
          {filtro === "proximos" && (
            <Link to="/" className="boton viajes-explorar">Explorar destinos</Link>
          )}
        </div>
      )}

      <div className="viajes-lista">
        {visibles.map((v) => (
          <article key={v.id_vp} className={`viaje viaje-${clasificar(v)}`}>
            <div className="viaje-cabecera">
              <div>
                <h2>{v.nombre_destino}</h2>
                <p className="viaje-hotel">🏨 {v.nombre_hotel}</p>
              </div>
              <span className={`viaje-estado estado-${clasificar(v)}`}>
                {clasificar(v) === "proximos" ? "Próximo" : clasificar(v) === "pasados" ? "Finalizado" : "Cancelado"}
              </span>
            </div>

            <div className="viaje-datos">
              <div>
                <small>Fechas</small>
                <strong>{fechaCorta(v.fecha_inicial)} – {fechaCorta(v.fecha_final)}</strong>
              </div>
              <div>
                <small>Duración</small>
                <strong>{v.noches} {v.noches === 1 ? "noche" : "noches"}</strong>
              </div>
              <div>
                <small>Personas</small>
                <strong>{v.num_personas}</strong>
              </div>
            </div>

            <ul className="viaje-habitaciones">
              {v.habitaciones.map((h) => (
                <li key={h.id_habitacion}>
                  <span>
                    🛏️ {h.nombre_habitacion} · {h.personas_asignadas}{" "}
                    {h.personas_asignadas === 1 ? "persona" : "personas"}
                  </span>
                  <span>{moneda(h.precio_noche)}/noche</span>
                </li>
              ))}
            </ul>

            <div className="viaje-pie">
              <div>
                <small>Total</small>
                <strong>{moneda(v.precio)}</strong>
              </div>
              {clasificar(v) === "proximos" && (
                <button
                  className="viaje-cancelar"
                  disabled={cancelando === v.id_vp}
                  onClick={() => cancelar(v.id_vp)}
                >
                  {cancelando === v.id_vp ? "Cancelando..." : "Cancelar reserva"}
                </button>
              )}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

export default MisViajes;