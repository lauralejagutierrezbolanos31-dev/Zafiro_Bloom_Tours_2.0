import { useEffect, useMemo, useState } from "react";

import { useAuth } from "../context/AuthContext";
import { habitacionService } from "../services/habitacionService";
import { viajeService } from "../services/viajeService";
import type { Habitacion } from "../types/habitacion";
import type { Hotel } from "../types/hotel";
import type { Viaje } from "../types/viaje";
import { mensajeError } from "../utils/errores";
import { calcularNoches, hoy, moneda } from "../utils/formato";
import { urlImagen } from "../utils/imagen";
import "./ModalHabitaciones.css";

interface Props {
  hotel: Hotel;
  onCerrar: () => void;
  onReservado: (viaje: Viaje) => void;
}

function ModalHabitaciones({ hotel, onCerrar, onReservado }: Props) {
  const { usuario, abrirAuth } = useAuth();

  const [inicio, setInicio] = useState("");
  const [fin, setFin] = useState("");
  const [personas, setPersonas] = useState(1);
  const [habitaciones, setHabitaciones] = useState<Habitacion[]>([]);
  const [seleccion, setSeleccion] = useState<Record<number, number>>({});
  const [cargando, setCargando] = useState(true);
  const [enviando, setEnviando] = useState(false);
  const [error, setError] = useState("");
  const [aviso, setAviso] = useState("");

  const noches = calcularNoches(inicio, fin);
  const fechasValidas = noches > 0;

  useEffect(() => {
    setCargando(true);
    habitacionService
      .listar(hotel.id_hotel, fechasValidas ? inicio : undefined, fechasValidas ? fin : undefined)
      .then((lista) => {
        setHabitaciones(lista);
        // quita de la selección las habitaciones que ya no están libres en esas fechas
        setSeleccion((s) => {
          const libres = new Set(lista.filter((h) => h.disponible).map((h) => h.id_habitacion));
          return Object.fromEntries(Object.entries(s).filter(([id]) => libres.has(Number(id))));
        });
      })
      .catch(() => setError("No se pudieron cargar las habitaciones."))
      .finally(() => setCargando(false));
  }, [hotel.id_hotel, inicio, fin, fechasValidas]);

  const asignadas = useMemo(
    () => Object.values(seleccion).reduce((a, b) => a + b, 0),
    [seleccion]
  );
  const faltan = personas - asignadas;

  const total = useMemo(
    () =>
      habitaciones.reduce((suma, h) => suma + (seleccion[h.id_habitacion] ? Number(h.precio) : 0), 0) *
      noches,
    [habitaciones, seleccion, noches]
  );

  const capacidadLibre = habitaciones
    .filter((h) => h.disponible)
    .reduce((a, h) => a + h.capacidad, 0);

  function cambiarPersonas(valor: number) {
    setPersonas(Math.max(1, Math.min(60, valor)));
    setSeleccion({});
    setAviso("");
  }

  function mover(h: Habitacion, delta: number) {
    setError("");
    setAviso("");
    setSeleccion((s) => {
      const actual = s[h.id_habitacion] ?? 0;
      const nuevo = Math.max(0, Math.min(h.capacidad, actual + delta));
      const copia = { ...s };
      if (nuevo === 0) delete copia[h.id_habitacion];
      else copia[h.id_habitacion] = nuevo;
      return copia;
    });
  }

  async function sugerir() {
    setError("");
    setAviso("");
    if (!fechasValidas) {
      setError("Elige primero las fechas de llegada y salida.");
      return;
    }
    try {
      const r = await viajeService.sugerir({
        id_hotel: hotel.id_hotel,
        fecha_inicial: inicio,
        fecha_final: fin,
        num_personas: personas,
      });
      if (!r.posible) {
        setError(r.mensaje);
        return;
      }
      setSeleccion(Object.fromEntries(r.habitaciones.map((h) => [h.id_habitacion, h.personas])));
      setAviso("Te sugerimos esta combinación. Puedes ajustarla.");
    } catch (err) {
      setError(mensajeError(err, "No se pudo generar la sugerencia."));
    }
  }

  async function confirmar() {
    setError("");
    if (!fechasValidas) {
      setError("Elige las fechas de llegada y salida (la salida debe ser posterior).");
      return;
    }
    if (faltan !== 0) {
      setError(`Faltan ${faltan} persona(s) por ubicar en habitaciones.`);
      return;
    }
    if (!usuario) {
      setError("Inicia sesión o crea tu cuenta para confirmar la reserva. Tu selección se conserva.");
      abrirAuth();
      return;
    }

    setEnviando(true);
    try {
      const viaje = await viajeService.crear({
        id_hotel: hotel.id_hotel,
        fecha_inicial: inicio,
        fecha_final: fin,
        num_personas: personas,
        habitaciones: Object.entries(seleccion).map(([id, p]) => ({
          id_habitacion: Number(id),
          personas: p,
        })),
      });
      onReservado(viaje);
    } catch (err) {
      setError(mensajeError(err, "No se pudo confirmar la reserva. Intenta de nuevo."));
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="hab-fondo" onClick={onCerrar}>
      <div className="hab-caja" onClick={(e) => e.stopPropagation()}>
        <button className="hab-cerrar" onClick={onCerrar} aria-label="Cerrar">✕</button>
        <h2>Escoge tus habitaciones en {hotel.nombre}</h2>

        <div className="hab-datos">
          <label>
            Llegada
            <input type="date" min={hoy()} value={inicio} onChange={(e) => setInicio(e.target.value)} />
          </label>
          <label>
            Salida
            <input type="date" min={inicio || hoy()} value={fin} onChange={(e) => setFin(e.target.value)} />
          </label>
          <label>
            ¿Cuántas personas viajan?
            <div className="hab-contador">
              <button type="button" onClick={() => cambiarPersonas(personas - 1)}>−</button>
              <span>{personas}</span>
              <button type="button" onClick={() => cambiarPersonas(personas + 1)}>+</button>
            </div>
          </label>
          <button className="boton hab-sugerir" type="button" onClick={sugerir}>
            ✨ Sugerir habitaciones
          </button>
        </div>

        {fechasValidas && capacidadLibre < personas && !cargando && (
          <p className="hab-alerta">
            En esas fechas el hotel solo tiene cupo para {capacidadLibre} persona(s).
          </p>
        )}

        {cargando ? (
          <p className="mensaje-carga">Cargando habitaciones...</p>
        ) : (
          <div className="hab-lista">
            {habitaciones.map((h) => {
              const cantidad = seleccion[h.id_habitacion] ?? 0;
              const puedeSumar = cantidad < h.capacidad && faltan > 0;
              return (
                <article
                  key={h.id_habitacion}
                  className={`hab-item ${cantidad > 0 ? "hab-item-elegida" : ""} ${
                    !h.disponible ? "hab-item-ocupada" : ""
                  }`}
                >
                  {h.foto_referencia && <img src={urlImagen(h.foto_referencia)} alt={h.nombre} />}
                  <div className="hab-item-cuerpo">
                    <h3>{h.nombre}</h3>
                    <p>
                      👤 Máximo {h.capacidad} {h.capacidad === 1 ? "persona" : "personas"}
                      {h.tipo_cama && <> · 🛏️ {h.tipo_cama}</>}
                    </p>
                    <p className="hab-precio">
                      Por noche: <strong>{moneda(h.precio)}</strong>
                    </p>

                    {h.disponible ? (
                      <div className="hab-contador">
                        <button type="button" disabled={cantidad === 0} onClick={() => mover(h, -1)}>−</button>
                        <span>{cantidad}</span>
                        <button type="button" disabled={!puedeSumar} onClick={() => mover(h, 1)}>+</button>
                        <small>personas aquí</small>
                      </div>
                    ) : (
                      <span className="hab-etiqueta-ocupada">Ocupada en esas fechas</span>
                    )}
                  </div>
                </article>
              );
            })}
          </div>
        )}

        <div className="hab-resumen">
          <div>
            <p>
              Personas ubicadas: <strong>{asignadas} de {personas}</strong>
              {faltan > 0 && <span className="hab-falta"> (faltan {faltan})</span>}
            </p>
            {noches > 0 && asignadas > 0 && (
              <p>
                {noches} {noches === 1 ? "noche" : "noches"} · Total: <strong>{moneda(total)}</strong>
              </p>
            )}
          </div>
          <button className="boton" type="button" disabled={enviando} onClick={confirmar}>
            {enviando ? "Confirmando..." : "Confirmar reserva"}
          </button>
        </div>

        {aviso && <p className="hab-aviso">{aviso}</p>}
        {error && <p className="mensaje-error">{error}</p>}
      </div>
    </div>
  );
}

export default ModalHabitaciones;