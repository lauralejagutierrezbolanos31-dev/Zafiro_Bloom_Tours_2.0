import { useEffect, useState } from "react";

import { useAuth } from "../context/AuthContext";
import { viajeService } from "../services/viajeService";
import type { Viaje } from "../types/viaje";
import { mensajeError } from "../utils/errores";
import { fechaCorta, moneda } from "../utils/formato";
import "./MisViajes.css";

function MisViajes() {
  const { usuario, abrirAuth } = useAuth();
  const [viajes, setViajes] = useState<Viaje[]>([]);
  const [cargando, setCargando] = useState(true);
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

  async function cancelar(id: number) {
    if (!window.confirm("¿Seguro que quieres cancelar esta reserva?")) return;
    try {
      const actualizado = await viajeService.cancelar(id);
      setViajes((lista) => lista.map((v) => (v.id_vp === id ? actualizado : v)));
    } catch (err) {
      setError(mensajeError(err, "No se pudo cancelar la reserva."));
    }
  }

  if (!usuario) {
    return (
      <div className="viajes-vacio">
        <p>Inicia sesión para ver tus viajes.</p>
        <button className="boton" onClick={abrirAuth}>Iniciar sesión</button>
      </div>
    );
  }

  return (
    <div className="viajes">
      <h1>Mis viajes</h1>
      {cargando && <p className="mensaje-carga">Cargando...</p>}
      {error && <p className="mensaje-error">{error}</p>}
      {!cargando && viajes.length === 0 && <p>Aún no tienes viajes reservados.</p>}

      <div className="viajes-lista">
        {viajes.map((v) => (
          <article key={v.id_vp} className={`viaje viaje-${v.estado}`}>
            <div className="viaje-cabecera">
              <h2>{v.nombre_destino}</h2>
              <span className="viaje-estado">{v.estado}</span>
            </div>
            <p className="viaje-hotel">🏨 {v.nombre_hotel}</p>
            <p>
              🗓️ {fechaCorta(v.fecha_inicial)} – {fechaCorta(v.fecha_final)} ({v.noches}{" "}
              {v.noches === 1 ? "noche" : "noches"})
            </p>
            <p>👥 {v.num_personas} {v.num_personas === 1 ? "persona" : "personas"}</p>

            <ul className="viaje-habitaciones">
              {v.habitaciones.map((h) => (
                <li key={h.id_habitacion}>
                  {h.nombre_habitacion} · {h.personas_asignadas}{" "}
                  {h.personas_asignadas === 1 ? "persona" : "personas"} · {moneda(h.precio_noche)}/noche
                </li>
              ))}
            </ul>

            <div className="viaje-pie">
              <strong>Total: {moneda(v.precio)}</strong>
              {v.estado === "reservado" && (
                <button className="viaje-cancelar" onClick={() => cancelar(v.id_vp)}>
                  Cancelar reserva
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