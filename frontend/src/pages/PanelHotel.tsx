import { useEffect, useState, type FormEvent } from "react";

import { panelService } from "../services/panelService";
import type { HabitacionForm, HabitacionPanel, HotelPanel, ReservaHotel } from "../types/panel";
import { mensajeError } from "../utils/errores";
import { fechaCorta, moneda } from "../utils/formato";
import "./PanelHotel.css";
import EncabezadoPagina from "../components/EncabezadoPagina";

const FORM_VACIO: HabitacionForm = {
  nombre: "", tipo_cama: "", capacidad: 2, precio: 100000, foto_referencia: "",
};

function PanelHotel() {
  const [hoteles, setHoteles] = useState<HotelPanel[]>([]);
  const [hotel, setHotel] = useState<HotelPanel | null>(null);
  const [habitaciones, setHabitaciones] = useState<HabitacionPanel[]>([]);
  const [reservas, setReservas] = useState<ReservaHotel[]>([]);
  const [pestana, setPestana] = useState<"habitaciones" | "reservas">("habitaciones");
  const [form, setForm] = useState<HabitacionForm>(FORM_VACIO);
  const [editando, setEditando] = useState<number | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    panelService
      .hoteles()
      .then((lista) => {
        setHoteles(lista);
        if (lista.length > 0) setHotel(lista[0]);
      })
      .catch((e) => setError(mensajeError(e, "No se pudieron cargar tus hoteles.")));
  }, []);

  function recargar(h: HotelPanel) {
    panelService.habitaciones(h.id_hotel).then(setHabitaciones);
    panelService.reservas(h.id_hotel).then(setReservas);
  }

  useEffect(() => {
    if (hotel) recargar(hotel);
  }, [hotel]);

  async function guardar(e: FormEvent) {
    e.preventDefault();
    if (!hotel) return;
    setError("");
    try {
      if (editando) {
        await panelService.editarHabitacion(editando, {
          ...form,
          tipo_cama: form.tipo_cama || undefined,
          foto_referencia: form.foto_referencia || undefined,
        });
      } else {
        await panelService.crearHabitacion(hotel.id_hotel, form);
      }
      setForm(FORM_VACIO);
      setEditando(null);
      recargar(hotel);
    } catch (err) {
      setError(mensajeError(err, "No se pudo guardar la habitación."));
    }
  }

  function editar(h: HabitacionPanel) {
    setEditando(h.id_habitacion);
    setForm({
      nombre: h.nombre,
      tipo_cama: h.tipo_cama ?? "",
      capacidad: h.capacidad,
      precio: Number(h.precio),
      foto_referencia: h.foto_referencia ?? "",
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  async function quitar(h: HabitacionPanel) {
    if (!hotel || !window.confirm(`¿Quitar "${h.nombre}"?`)) return;
    setError("");
    try {
      await panelService.quitarHabitacion(h.id_habitacion);
      recargar(hotel);
    } catch (err) {
      setError(mensajeError(err, "No se pudo quitar la habitación."));
    }
  }

  async function reactivar(h: HabitacionPanel) {
    if (!hotel) return;
    await panelService.editarHabitacion(h.id_habitacion, { activa: true });
    recargar(hotel);
  }

  if (!hotel && !error) {
    return <p className="mensaje-carga">No tienes hoteles asignados todavía.</p>;
  }

  return (
    <div className="panel-hotel">
      <EncabezadoPagina titulo="Panel del hotel" subtitulo="Gestiona tus habitaciones y revisa tus reservas." />

      {hoteles.length > 1 && (
        <select
          className="panel-hotel-selector"
          value={hotel?.id_hotel}
          onChange={(e) => setHotel(hoteles.find((h) => h.id_hotel === Number(e.target.value)) ?? null)}
        >
          {hoteles.map((h) => (
            <option key={h.id_hotel} value={h.id_hotel}>{h.nombre}</option>
          ))}
        </select>
      )}
      {hotel && <p className="panel-hotel-nombre">🏨 {hotel.nombre}</p>}
      {error && <p className="mensaje-error">{error}</p>}

      <div className="panel-hotel-pestanas">
        <button className={pestana === "habitaciones" ? "activa" : ""} onClick={() => setPestana("habitaciones")}>
          Habitaciones
        </button>
        <button className={pestana === "reservas" ? "activa" : ""} onClick={() => setPestana("reservas")}>
          Reservas ({reservas.length})
        </button>
      </div>

      {pestana === "habitaciones" && (
        <>
          <form className="panel-hotel-form" onSubmit={guardar}>
            <h2>{editando ? "Editar habitación" : "Nueva habitación"}</h2>
            <div className="panel-hotel-fila">
              <label>
                Nombre
                <input required value={form.nombre} onChange={(e) => setForm({ ...form, nombre: e.target.value })} />
              </label>
              <label>
                Tipo de cama
                <input
                  placeholder="1 cama doble"
                  value={form.tipo_cama}
                  onChange={(e) => setForm({ ...form, tipo_cama: e.target.value })}
                />
              </label>
            </div>
            <div className="panel-hotel-fila">
              <label>
                Capacidad (personas)
                <input
                  type="number" min={1} max={10} required value={form.capacidad}
                  onChange={(e) => setForm({ ...form, capacidad: Number(e.target.value) })}
                />
              </label>
              <label>
                Precio por noche
                <input
                  type="number" min={1} required value={form.precio}
                  onChange={(e) => setForm({ ...form, precio: Number(e.target.value) })}
                />
              </label>
            </div>
            <label>
              URL de la foto (opcional)
              <input
                value={form.foto_referencia}
                onChange={(e) => setForm({ ...form, foto_referencia: e.target.value })}
              />
            </label>
            <div className="panel-hotel-botones">
              <button className="boton" type="submit">{editando ? "Guardar cambios" : "Agregar habitación"}</button>
              {editando && (
                <button
                  type="button"
                  className="panel-hotel-cancelar"
                  onClick={() => {
                    setEditando(null);
                    setForm(FORM_VACIO);
                  }}
                >
                  Cancelar
                </button>
              )}
            </div>
          </form>

          <div className="panel-hotel-tabla">
            {habitaciones.map((h) => (
              <div key={h.id_habitacion} className={`panel-hotel-fila-hab ${h.activa ? "" : "inactiva"}`}>
                <div>
                  <strong>{h.nombre}</strong>
                  <small>
                    👤 {h.capacidad} · {h.tipo_cama || "sin tipo de cama"} · {moneda(h.precio)}/noche
                    {!h.activa && " · (inactiva)"}
                  </small>
                </div>
                <div className="panel-hotel-acciones">
                  <button onClick={() => editar(h)}>Editar</button>
                  {h.activa ? (
                    <button className="peligro" onClick={() => quitar(h)}>Quitar</button>
                  ) : (
                    <button onClick={() => reactivar(h)}>Reactivar</button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </>
      )}

      {pestana === "reservas" && (
        <div className="panel-hotel-tabla">
          {reservas.length === 0 && <p className="mensaje-carga">Aún no hay reservas en este hotel.</p>}
          {reservas.map((r) => (
            <div key={r.id_vp} className="panel-hotel-reserva">
              <div className="panel-hotel-reserva-cab">
                <strong>{r.cliente}</strong>
                <span className={`estado-${r.estado}`}>{r.estado}</span>
              </div>
              <small>{r.correo_cliente}</small>
              <p>
                🗓️ {fechaCorta(r.fecha_inicial)} – {fechaCorta(r.fecha_final)} · 👥 {r.num_personas} ·{" "}
                <strong>{moneda(r.precio)}</strong>
              </p>
              <p className="panel-hotel-habs">{r.habitaciones.join(" · ")}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default PanelHotel;