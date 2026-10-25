import { Link, Navigate, useLocation } from "react-router-dom";

import type { Viaje } from "../types/viaje";
import { fechaCorta, moneda } from "../utils/formato";
import "./ViajeExitoso.css";

function ViajeExitoso() {
  const { state } = useLocation();
  const viaje = (state as { viaje?: Viaje } | null)?.viaje;

  // Si alguien entra directo a esta página (sin reservar), lo llevamos a Mis viajes
  if (!viaje) return <Navigate to="/mis-viajes" replace />;

  return (
    <div className="exito">
      <div className="exito-icono">✅</div>
      <h1>¡Reserva confirmada!</h1>
      <p className="exito-lema">Tu aventura en {viaje.nombre_destino} ya está lista.</p>

      <section className="exito-resumen">
        <h2>Resumen de tu viaje</h2>

        <div className="exito-fila">
          <span>Reserva</span>
          <strong>#{viaje.id_vp}</strong>
        </div>
        <div className="exito-fila">
          <span>Destino</span>
          <strong>{viaje.nombre_destino}</strong>
        </div>
        <div className="exito-fila">
          <span>Hotel</span>
          <strong>{viaje.nombre_hotel}</strong>
        </div>
        <div className="exito-fila">
          <span>Fechas</span>
          <strong>
            {fechaCorta(viaje.fecha_inicial)} – {fechaCorta(viaje.fecha_final)}
          </strong>
        </div>
        <div className="exito-fila">
          <span>Duración</span>
          <strong>
            {viaje.noches} {viaje.noches === 1 ? "noche" : "noches"}
          </strong>
        </div>
        <div className="exito-fila">
          <span>Personas</span>
          <strong>{viaje.num_personas}</strong>
        </div>

        <h3>Habitaciones</h3>
        <ul className="exito-habitaciones">
          {viaje.habitaciones.map((h) => (
            <li key={h.id_habitacion}>
              <span>
                {h.nombre_habitacion} · {h.personas_asignadas}{" "}
                {h.personas_asignadas === 1 ? "persona" : "personas"}
              </span>
              <span>{moneda(h.precio_noche)}/noche</span>
            </li>
          ))}
        </ul>

        <div className="exito-total">
          <span>Total</span>
          <strong>{moneda(viaje.precio)}</strong>
        </div>
      </section>

      <div className="exito-botones">
        <Link to="/mis-viajes" className="boton exito-boton">Ver mis viajes</Link>
        <Link to="/" className="exito-secundario">Seguir explorando</Link>
      </div>
    </div>
  );
}

export default ViajeExitoso;