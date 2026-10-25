import { useState, type FormEvent } from "react";

import { useAuth } from "../context/AuthContext";
import { mensajeError } from "../utils/errores";
import "./AuthModal.css";

function AuthModal() {
  const { modalAbierto, cerrarAuth, iniciarSesion, registrarse } = useAuth();
  const [registro, setRegistro] = useState(false);
  const [error, setError] = useState("");
  const [enviando, setEnviando] = useState(false);
  const [form, setForm] = useState({
    nombre: "", apellidos: "", ciudad: "", direccion: "", telefono: "", correo: "", contrasena: "",
  });

  if (!modalAbierto) return null;

  function cambiar(campo: string, valor: string) {
    setForm((f) => ({ ...f, [campo]: valor }));
  }

  function cerrar() {
    setError("");
    cerrarAuth();
  }

  async function enviar(e: FormEvent) {
    e.preventDefault();
    setError("");
    setEnviando(true);
    try {
      if (registro) {
        await registrarse({
          nombre: form.nombre,
          apellidos: form.apellidos || undefined,
          ciudad: form.ciudad || undefined,
          direccion: form.direccion || undefined,
          telefono: form.telefono || undefined,
          correo: form.correo,
          contrasena: form.contrasena,
        });
      } else {
        await iniciarSesion(form.correo, form.contrasena);
      }
      setForm((f) => ({ ...f, contrasena: "" }));
      cerrarAuth();
    } catch (err) {
      setError(mensajeError(err, "No se pudo completar la solicitud. Intenta de nuevo."));
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="auth-fondo" onClick={cerrar}>
      <div className="auth-caja" onClick={(e) => e.stopPropagation()}>
        <button className="auth-cerrar" onClick={cerrar} aria-label="Cerrar">✕</button>
        <h2>{registro ? "Crear una cuenta" : "Iniciar sesión"}</h2>
        <p className="auth-sub">
          {registro
            ? "Ingresa tus datos para registrarte y empezar tu viaje"
            : "Inicia sesión para continuar con tu reserva"}
        </p>

        <form onSubmit={enviar} className="auth-form">
          {registro && (
            <>
              <div className="auth-fila">
                <label>
                  Nombre
                  <input required value={form.nombre} onChange={(e) => cambiar("nombre", e.target.value)} />
                </label>
                <label>
                  Apellidos
                  <input value={form.apellidos} onChange={(e) => cambiar("apellidos", e.target.value)} />
                </label>
              </div>
              <label>
                Ciudad
                <input value={form.ciudad} onChange={(e) => cambiar("ciudad", e.target.value)} placeholder="Ej. Bogotá" />
              </label>
              <div className="auth-fila">
                <label>
                  Dirección
                  <input value={form.direccion} onChange={(e) => cambiar("direccion", e.target.value)} />
                </label>
                <label>
                  Teléfono
                  <input type="tel" value={form.telefono} onChange={(e) => cambiar("telefono", e.target.value)} />
                </label>
              </div>
            </>
          )}

          <label>
            Correo electrónico
            <input
              type="email"
              required
              value={form.correo}
              onChange={(e) => cambiar("correo", e.target.value)}
              placeholder="tucorreo@email.com"
            />
          </label>
          <label>
            Contraseña
            <input
              type="password"
              required
              minLength={registro ? 8 : undefined}
              value={form.contrasena}
              onChange={(e) => cambiar("contrasena", e.target.value)}
              placeholder={registro ? "Mínimo 8 caracteres" : "••••••••"}
            />
          </label>

          {error && <p className="auth-error">{error}</p>}

          <button className="boton auth-enviar" type="submit" disabled={enviando}>
            {enviando ? "Cargando..." : registro ? "Registrarse" : "Iniciar sesión"}
          </button>
        </form>

        <button
          className="auth-cambio"
          type="button"
          onClick={() => {
            setRegistro(!registro);
            setError("");
          }}
        >
          {registro ? "¿Ya tienes cuenta? Inicia sesión aquí" : "¿No tienes cuenta? Regístrate aquí"}
        </button>
      </div>
    </div>
  );
}

export default AuthModal;