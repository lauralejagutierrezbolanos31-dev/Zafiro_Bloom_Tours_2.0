import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";

import { useAuth } from "../context/AuthContext";
import { usuarioService } from "../services/usuarioService";
import { mensajeError } from "../utils/errores";
import "./Cuenta.css";

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
  const [mensaje, setMensaje] = useState("");
  const [error, setError] = useState("");
  const [contrasena, setContrasena] = useState("");
  const [confirmando, setConfirmando] = useState(false);

  if (!usuario) {
    return (
      <div className="cuenta-vacia">
        <p>Inicia sesión para ver tu cuenta.</p>
        <button className="boton" onClick={abrirAuth}>Iniciar sesión</button>
      </div>
    );
  }

  async function guardar(e: FormEvent) {
    e.preventDefault();
    setMensaje("");
    setError("");
    try {
      actualizarUsuario(await usuarioService.editar(form));
      setMensaje("Datos actualizados correctamente.");
    } catch (err) {
      setError(mensajeError(err, "No se pudieron guardar los cambios."));
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
      <h1>Mi cuenta</h1>
      <p className="cuenta-correo">{usuario.correo}</p>

      <form className="cuenta-form" onSubmit={guardar}>
        {(["nombre", "apellidos", "ciudad", "direccion", "telefono"] as const).map((campo) => (
          <label key={campo}>
            {campo.charAt(0).toUpperCase() + campo.slice(1)}
            <input
              value={form[campo]}
              required={campo === "nombre"}
              onChange={(e) => setForm({ ...form, [campo]: e.target.value })}
            />
          </label>
        ))}
        <button className="boton" type="submit">Guardar cambios</button>
        {mensaje && <p className="cuenta-ok">{mensaje}</p>}
      </form>

      <section className="cuenta-peligro">
        <h2>Eliminar cuenta</h2>
        <p>Tu cuenta se desactivará y ya no podrás iniciar sesión.</p>
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
          </div>
        )}
      </section>

      {error && <p className="mensaje-error">{error}</p>}
    </div>
  );
}

export default Cuenta;