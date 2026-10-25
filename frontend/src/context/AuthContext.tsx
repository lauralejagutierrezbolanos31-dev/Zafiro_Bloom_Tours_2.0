import { createContext, useContext, useState, type ReactNode } from "react";

import { authService } from "../services/authService";
import type { RegistroDatos, RespuestaAuth, Usuario } from "../types/usuario";

interface AuthContextValor {
  usuario: Usuario | null;
  modalAbierto: boolean;
  abrirAuth: () => void;
  cerrarAuth: () => void;
  iniciarSesion: (correo: string, contrasena: string) => Promise<void>;
  registrarse: (datos: RegistroDatos) => Promise<void>;
  cerrarSesion: () => void;
  actualizarUsuario: (usuario: Usuario) => void;
}

const AuthContext = createContext<AuthContextValor | null>(null);

function leerUsuarioGuardado(): Usuario | null {
  try {
    const guardado = localStorage.getItem("usuario");
    return guardado ? (JSON.parse(guardado) as Usuario) : null;
  } catch {
    return null;
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [usuario, setUsuario] = useState<Usuario | null>(leerUsuarioGuardado);
  const [modalAbierto, setModalAbierto] = useState(false);

  function guardarSesion(respuesta: RespuestaAuth) {
    localStorage.setItem("token", respuesta.access_token);
    localStorage.setItem("usuario", JSON.stringify(respuesta.usuario));
    setUsuario(respuesta.usuario);
  }

  async function iniciarSesion(correo: string, contrasena: string) {
    guardarSesion(await authService.login(correo, contrasena));
  }

  async function registrarse(datos: RegistroDatos) {
    guardarSesion(await authService.registro(datos));
  }

  function cerrarSesion() {
    localStorage.removeItem("token");
    localStorage.removeItem("usuario");
    setUsuario(null);
  }

  function actualizarUsuario(nuevo: Usuario) {
    localStorage.setItem("usuario", JSON.stringify(nuevo));
    setUsuario(nuevo);
  }

  return (
    <AuthContext.Provider
      value={{
        usuario,
        modalAbierto,
        abrirAuth: () => setModalAbierto(true),
        cerrarAuth: () => setModalAbierto(false),
        iniciarSesion,
        registrarse,
        cerrarSesion,
        actualizarUsuario,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const contexto = useContext(AuthContext);
  if (!contexto) throw new Error("useAuth debe usarse dentro de AuthProvider");
  return contexto;
}