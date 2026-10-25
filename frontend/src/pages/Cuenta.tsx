import { useState, type FormEvent } from "react";
import { Link, useNavigate } from "react-router-dom";

import EncabezadoPagina from "../components/EncabezadoPagina";
import { useAuth } from "../context/AuthContext";
import { usuarioService } from "../services/usuarioService";
import { mensajeError } from "../utils/errores";
import "./Cuenta.css";

const ROLES: Record<string, string> = {
  usuario: "Viajero",
  admin_hotel: "Administrador de hotel",
  super_admin: "Super administrador",
};

function Cuenta() {
  const { usuario, abrirAuth, actualizarUsuario, cerrarSesion } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    nombre: usuario?.nombre ?? "",
    apellidos: usuario?.apellidos ?? "",
    ciudad: usuario?.ciudad ?? "",
    direccion: usuario?.direccion ?? "",
    telefono: usuario?.telefono ?? "",
  });
  const [guardando, setGuardando] = useState(false);
  const [mensaje, setMensaje] = useState("");
  const [error, setError] = useState("");
  const [contrasena, setContrasena] = useState("");
  const [confirmando, setConfirmando] = useState(false);

  if (!usuario) {
    return (
      <div className="cuenta">
        <EncabezadoPagina titulo="Mi cuenta" />
        <div className="cuenta-vacia">
          <span>🔒</span>
          <p>Inicia sesión para ver tu cuenta.</p>
          <button className="boton" onClick={abrirAuth}>Iniciar sesión</button>
        </div>
      </div>
    );
  }

  const iniciales = `${usuario.nombre[0] ?? ""}${usuario.apellidos?.[0] ?? ""}`.toUpperCase();

  async function guardar(e: FormEvent) {
    e.preventDefault();
    setMensaje("");
    setError("");
    setGuardando(true);
    try {
      actualizarUsuario(await usuarioService.editar(form));
      setMensaje("✅ Tus datos se guardaron correctamente.");
    } catch (err) {
      setError(mensajeError(err, "No se pudieron guardar los cambios."));
    } finally {
      setGuardando(false);
    }
  }

  async function eliminar() {
    setError("");
    try {
      await usuarioService.eliminar(contrasena);
      cerrarSesion();
      navigate("/");
    } catch (err) {
      setError(mensajeError(err, "No se pudo eliminar la cuenta."));
    }
  }

  return (
    <div className="cuenta">
      <EncabezadoPagina titulo="Mi cuenta" subtitulo="Revisa y actualiza tus datos personales." />

      <div className="cuenta-grid">
        <aside className="cuenta-perfil">
          <div className="cuenta-avatar">{iniciales || "👤"}</div>
          <h2>{usuario.nombre} {usuario.apellidos}</h2>
          <p className="cuenta-correo">{usuario.correo}</p>
          <span className="cuenta-rol">{ROLES[usuario.rol] ?? usuario.rol}</span>

          <nav className="cuenta-atajos">
            <Link to="/mis-viajes">🧳 Mis viajes</Link>
            <Link to="/">🏠 Ir al inicio</Link>
            <button
              onClick={() => {
                cerrarSesion();
                navigate("/");
              }}
            >
              🚪 Cerrar sesión
            </button>
          </nav>
        </aside>

        <section className="cuenta-contenido">
          <form className="cuenta-form" onSubmit={guardar}>
            <h2>Datos personales</h2>

            <div className="cuenta-fila">
              <label>
                Nombre
                <input required value={form.nombre} onChange={(e) => setForm({ ...form, nombre: e.target.value })} />
              </label>
              <label>
                Apellidos
                <input value={form.apellidos} onChange={(e) => setForm({ ...form, apellidos: e.target.value })} />
              </label>
            </div>

            <div className="cuenta-fila">
              <label>
                Ciudad
                <input value={form.ciudad} onChange={(e) => setForm({ ...form, ciudad: e.target.value })} />
              </label>
              <label>
                Teléfono
                <input value={form.telefono} onChange={(e) => setForm({ ...form, telefono: e.target.value })} />
              </label>
            </div>

            <label>
              Dirección
              <input value={form.direccion} onChange={(e) => setForm({ ...form, direccion: e.target.value })} />
            </label>

            <label>
              Correo electrónico
              <input value={usuario.correo} disabled />
              <small>El correo no se puede cambiar.</small>
            </label>

            <button className="boton" type="submit" disabled={guardando}>
              {guardando ? "Guardando..." : "Guardar cambios"}
            </button>
            {mensaje && <p className="cuenta-ok">{mensaje}</p>}
          </form>

          <section className="cuenta-peligro">
            <h2>Zona de cuidado</h2>
            <p>
              Si eliminas tu cuenta ya no podrás iniciar sesión. Tus reservas anteriores se conservan
              como historial.
            </p>
            {!confirmando ? (
              <button className="cuenta-eliminar" onClick={() => setConfirmando(true)}>
                Eliminar mi cuenta
              </button>
            ) : (
              <div className="cuenta-confirmar">
                <input
                  type="password"
                  placeholder="Escribe tu contraseña para confirmar"
                  value={contrasena}
                  onChange={(e) => setContrasena(e.target.value)}
                />
                <button className="cuenta-eliminar" onClick={eliminar}>Confirmar eliminación</button>
                <button className="cuenta-cancelar" onClick={() => setConfirmando(false)}>Cancelar</button>
              </div>
            )}
          </section>

          {error && <p className="mensaje-error">{error}</p>}
        </section>
      </div>
    </div>
  );
}

export default Cuenta;