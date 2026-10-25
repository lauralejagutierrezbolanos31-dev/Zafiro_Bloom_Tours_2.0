import { useEffect, useState, type FormEvent } from "react";

import { deptoService } from "../services/deptoService";
import { destinoService } from "../services/destinoService";
import { feriaAdminService } from "../services/feriaAdminService";
import type { Depto } from "../types/depto";
import type { Destino } from "../types/destino";
import type { FeriaAdmin } from "../types/feria";
import { mensajeError } from "../utils/errores";
import { fechaCorta } from "../utils/formato";
import "./PanelFerias.css";

const VACIO = {
  nombre: "",
  tipo: "feria" as "feria" | "oferta",
  descripcion: "",
  foto_referencia: "",
  id_depto: "",
  id_destino: "",
  fecha_inicio: "",
  fecha_fin: "",
  descuento_porcentaje: "",
  activo: true,
};

function PanelFerias() {
  const [ferias, setFerias] = useState<FeriaAdmin[]>([]);
  const [deptos, setDeptos] = useState<Depto[]>([]);
  const [destinos, setDestinos] = useState<Destino[]>([]);
  const [form, setForm] = useState(VACIO);
  const [editando, setEditando] = useState<number | null>(null);
  const [error, setError] = useState("");
  const [aviso, setAviso] = useState("");

  function cargar() {
    feriaAdminService
      .listar()
      .then(setFerias)
      .catch((e) => setError(mensajeError(e, "No se pudieron cargar las ferias.")));
  }

  useEffect(() => {
    cargar();
    deptoService.listar().then(setDeptos).catch(() => setDeptos([]));
    destinoService.listar().then(setDestinos).catch(() => setDestinos([]));
  }, []);

  const destinosVisibles = form.id_depto
    ? destinos.filter((d) => String(d.id_depto) === form.id_depto)
    : destinos;

  function cambiarDepto(valor: string) {
    setForm((f) => ({ ...f, id_depto: valor, id_destino: "" }));
  }

  function cambiarDestino(valor: string) {
    const destino = destinos.find((d) => String(d.id_destino) === valor);
    setForm((f) => ({
      ...f,
      id_destino: valor,
      id_depto: destino ? String(destino.id_depto) : f.id_depto,
    }));
  }

  async function guardar(e: FormEvent) {
    e.preventDefault();
    setError("");
    setAviso("");

    const datos = {
      nombre: form.nombre.trim(),
      tipo: form.tipo,
      descripcion: form.descripcion.trim() || null,
      foto_referencia: form.foto_referencia.trim() || null,
      id_depto: form.id_depto ? Number(form.id_depto) : null,
      id_destino: form.id_destino ? Number(form.id_destino) : null,
      fecha_inicio: form.fecha_inicio || null,
      fecha_fin: form.fecha_fin || null,
      descuento_porcentaje:
        form.tipo === "oferta" && form.descuento_porcentaje
          ? Number(form.descuento_porcentaje)
          : null,
      activo: form.activo,
    };

    try {
      if (editando) {
        await feriaAdminService.actualizar(editando, datos);
        setAviso("Cambios guardados.");
      } else {
        await feriaAdminService.crear(datos);
        setAviso(form.tipo === "oferta" ? "Oferta creada." : "Feria creada.");
      }
      limpiar();
      cargar();
    } catch (err) {
      setError(mensajeError(err, "No se pudo guardar. Revisa los datos."));
    }
  }

  function limpiar() {
    setForm(VACIO);
    setEditando(null);
  }

  function editar(f: FeriaAdmin) {
    setEditando(f.id_feria);
    setError("");
    setAviso("");
    setForm({
      nombre: f.nombre,
      tipo: f.tipo,
      descripcion: f.descripcion ?? "",
      foto_referencia: f.foto_referencia ?? "",
      id_depto: f.id_depto ? String(f.id_depto) : "",
      id_destino: f.id_destino ? String(f.id_destino) : "",
      fecha_inicio: f.fecha_inicio ?? "",
      fecha_fin: f.fecha_fin ?? "",
      descuento_porcentaje: f.descuento_porcentaje ? String(Number(f.descuento_porcentaje)) : "",
      activo: f.activo,
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  async function eliminar(f: FeriaAdmin) {
    if (!window.confirm(`¿Eliminar "${f.nombre}"? Esta acción no se puede deshacer.`)) return;
    setError("");
    try {
      await feriaAdminService.eliminar(f.id_feria);
      if (editando === f.id_feria) limpiar();
      cargar();
    } catch (err) {
      setError(mensajeError(err, "No se pudo eliminar."));
    }
  }

  return (
    <div className="panel-ferias">
      <h1>Ferias y ofertas</h1>

      <form className="panel-ferias-form" onSubmit={guardar}>
        <h2>{editando ? "Editar" : "Nueva feria u oferta"}</h2>

        <div className="pf-fila">
          <label>
            Nombre
            <input required value={form.nombre} onChange={(e) => setForm({ ...form, nombre: e.target.value })} />
          </label>
          <label>
            Tipo
            <select
              value={form.tipo}
              onChange={(e) => setForm({ ...form, tipo: e.target.value as "feria" | "oferta" })}
            >
              <option value="feria">Feria o fiesta</option>
              <option value="oferta">Oferta relámpago</option>
            </select>
          </label>
        </div>

        <label>
          Descripción
          <textarea rows={2} value={form.descripcion} onChange={(e) => setForm({ ...form, descripcion: e.target.value })} />
        </label>

        <div className="pf-fila">
          <label>
            Departamento
            <select value={form.id_depto} onChange={(e) => cambiarDepto(e.target.value)}>
              <option value="">Sin departamento</option>
              {deptos.map((d) => (
                <option key={d.id_depto} value={d.id_depto}>{d.nombre}</option>
              ))}
            </select>
          </label>
          <label>
            Municipio o destino
            <select value={form.id_destino} onChange={(e) => cambiarDestino(e.target.value)}>
              <option value="">Todo el departamento</option>
              {destinosVisibles.map((d) => (
                <option key={d.id_destino} value={d.id_destino}>{d.nombre}</option>
              ))}
            </select>
          </label>
        </div>

        <div className="pf-fila">
          <label>
            Fecha de inicio
            <input type="date" value={form.fecha_inicio} onChange={(e) => setForm({ ...form, fecha_inicio: e.target.value })} />
          </label>
          <label>
            Fecha final
            <input type="date" min={form.fecha_inicio || undefined} value={form.fecha_fin} onChange={(e) => setForm({ ...form, fecha_fin: e.target.value })} />
          </label>
        </div>

        {form.tipo === "oferta" && (
          <label>
            Descuento (%)
            <input
              type="number" min={1} max={100} required value={form.descuento_porcentaje}
              onChange={(e) => setForm({ ...form, descuento_porcentaje: e.target.value })}
            />
          </label>
        )}

        <label>
          Ruta de la foto (opcional, ej. /ferias/torbellino.jpg)
          <input value={form.foto_referencia} onChange={(e) => setForm({ ...form, foto_referencia: e.target.value })} />
        </label>

        <label className="pf-check">
          <input type="checkbox" checked={form.activo} onChange={(e) => setForm({ ...form, activo: e.target.checked })} />
          Visible para los usuarios
        </label>

        <div className="pf-botones">
          <button className="boton" type="submit">{editando ? "Guardar cambios" : "Crear"}</button>
          {editando && (
            <button type="button" className="pf-cancelar" onClick={limpiar}>Cancelar</button>
          )}
        </div>
      </form>

      {aviso && <p className="pf-ok">{aviso}</p>}
      {error && <p className="mensaje-error">{error}</p>}

      <div className="pf-lista">
        {ferias.length === 0 && <p className="mensaje-carga">Aún no hay ferias ni ofertas.</p>}
        {ferias.map((f) => (
          <article key={f.id_feria} className={`pf-item pf-${f.tipo} ${f.activo ? "" : "pf-inactiva"}`}>
            <div>
              <strong>{f.nombre}</strong>
              {f.tipo === "oferta" && f.descuento_porcentaje && (
                <span className="pf-etiqueta">-{Number(f.descuento_porcentaje)}%</span>
              )}
              {!f.activo && <span className="pf-etiqueta pf-oculta">oculta</span>}
              <small>
                {f.tipo === "oferta" ? "Oferta" : "Feria"}
                {(f.nombre_destino || f.nombre_depto) &&
                  ` · 📍 ${[f.nombre_destino, f.nombre_depto].filter(Boolean).join(", ")}`}
                {f.fecha_inicio && ` · 🗓️ ${fechaCorta(f.fecha_inicio)}`}
                {f.fecha_fin && ` – ${fechaCorta(f.fecha_fin)}`}
              </small>
            </div>
            <div className="pf-acciones">
              <button onClick={() => editar(f)}>Editar</button>
              <button className="peligro" onClick={() => eliminar(f)}>Eliminar</button>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

export default PanelFerias;