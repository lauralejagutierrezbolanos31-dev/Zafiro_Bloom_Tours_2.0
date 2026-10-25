import { useEffect, useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";

import { destinoService } from "../services/destinoService";
import { solicitudService } from "../services/solicitudService";
import type { Destino } from "../types/destino";
import { mensajeError } from "../utils/errores";
import "./SolicitarAcceso.css";

const INICIAL = {
  nombre: "", apellidos: "", documento: "", cargo: "Propietario", correo: "", telefono: "",
  contrasena: "", nombre_hotel: "", direccion_hotel: "", contacto_hotel: "",
  categoria: "Hotel Boutique", descripcion: "", politicas: "", id_destino: "",
};

function SolicitarAcceso() {
  const navigate = useNavigate();
  const [paso, setPaso] = useState<1 | 2>(1);
  const [form, setForm] = useState(INICIAL);
  const [destinos, setDestinos] = useState<Destino[]>([]);
  const [error, setError] = useState("");
  const [exito, setExito] = useState("");
  const [enviando, setEnviando] = useState(false);

  useEffect(() => {
    destinoService.listar().then(setDestinos).catch(() => setDestinos([]));
  }, []);

  function cambiar(e: { target: { name: string; value: string } }) {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
  }

  function siguiente(e: FormEvent) {
    e.preventDefault();
    if (form.contrasena.length < 8) {
      setError("La contraseña debe tener mínimo 8 caracteres.");
      return;
    }
    setError("");
    setPaso(2);
  }

  async function enviar(e: FormEvent) {
    e.preventDefault();
    setError("");
    setEnviando(true);
    try {
      const r = await solicitudService.enviar({
        ...form,
        id_destino: form.id_destino ? Number(form.id_destino) : null,
      });
      setExito(r.mensaje);
      setTimeout(() => navigate("/"), 4000);
    } catch (err) {
      setError(mensajeError(err, "Hubo un error al enviar la solicitud. Inténtalo de nuevo."));
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="solicitud">
      <h2>Solicitud de acceso administrador</h2>
      <p className="solicitud-sub">
        {paso === 1
          ? "Paso 1 de 2: tus datos personales y de contacto"
          : "Paso 2 de 2: información de tu hotel o alojamiento"}
      </p>

      <div className="solicitud-pasos">
        <span className={paso === 1 ? "paso-activo" : "paso-hecho"} />
        <span className={paso === 2 ? "paso-activo" : ""} />
      </div>

      {exito && <p className="solicitud-exito">{exito}</p>}
      {error && <p className="solicitud-error">{error}</p>}

      {paso === 1 && !exito && (
        <form onSubmit={siguiente} className="solicitud-form">
          <div className="solicitud-fila">
            <label>Nombre *<input name="nombre" required value={form.nombre} onChange={cambiar} /></label>
            <label>Apellidos<input name="apellidos" value={form.apellidos} onChange={cambiar} /></label>
          </div>
          <div className="solicitud-fila">
            <label>Documento de identidad *<input name="documento" required value={form.documento} onChange={cambiar} /></label>
            <label>
              Cargo o relación *
              <select name="cargo" value={form.cargo} onChange={cambiar}>
                <option>Propietario</option>
                <option>Gerente General</option>
                <option>Director de Marketing</option>
                <option>Administrador</option>
              </select>
            </label>
          </div>
          <div className="solicitud-fila">
            <label>Correo electrónico *<input type="email" name="correo" required value={form.correo} onChange={cambiar} /></label>
            <label>Teléfono de contacto<input name="telefono" value={form.telefono} onChange={cambiar} /></label>
          </div>
          <label>
            Contraseña * (mínimo 8 caracteres)
            <input type="password" name="contrasena" required value={form.contrasena} onChange={cambiar} />
          </label>
          <button className="boton" type="submit">Siguiente: datos del hotel →</button>
        </form>
      )}

      {paso === 2 && !exito && (
        <form onSubmit={enviar} className="solicitud-form">
          <label>Nombre del hotel *<input name="nombre_hotel" required value={form.nombre_hotel} onChange={cambiar} /></label>
          <label>
            Destino donde está ubicado
            <select name="id_destino" value={form.id_destino} onChange={cambiar}>
              <option value="">Mi destino aún no está en la lista</option>
              {destinos.map((d) => (
                <option key={d.id_destino} value={d.id_destino}>{d.nombre}</option>
              ))}
            </select>
          </label>
          <div className="solicitud-fila">
            <label>Dirección completa *<input name="direccion_hotel" required value={form.direccion_hotel} onChange={cambiar} /></label>
            <label>Contacto del hotel *<input name="contacto_hotel" required placeholder="Teléfono / recepción" value={form.contacto_hotel} onChange={cambiar} /></label>
          </div>
          <label>
            Categoría y tipo de hospedaje *
            <select name="categoria" value={form.categoria} onChange={cambiar}>
              <option>Hotel Boutique</option>
              <option>Cabaña Campestre</option>
              <option>Hostal Tradicional</option>
              <option>Finca Turística</option>
            </select>
          </label>
          <label>
            Descripción del hotel *
            <textarea name="descripcion" rows={3} required value={form.descripcion} onChange={cambiar} />
          </label>
          <label>
            Políticas del establecimiento *
            <textarea name="politicas" rows={2} required placeholder="Check-in, cancelación, mascotas..." value={form.politicas} onChange={cambiar} />
          </label>
          <div className="solicitud-botones">
            <button type="button" className="solicitud-atras" onClick={() => setPaso(1)}>← Atrás</button>
            <button className="boton" type="submit" disabled={enviando}>
              {enviando ? "Enviando..." : "Enviar solicitud al Super Administrador"}
            </button>
          </div>
        </form>
      )}
    </div>
  );
}

export default SolicitarAcceso;