import type { ReactNode } from "react";

import { useAuth } from "../context/AuthContext";
import type { Usuario } from "../types/usuario";

interface Props {
  roles: Usuario["rol"][];
  children: ReactNode;
}

function RutaProtegida({ roles, children }: Props) {
  const { usuario, abrirAuth } = useAuth();

  if (!usuario) {
    return (
      <div style={{ textAlign: "center", padding: "4rem 1rem" }}>
        <p>Inicia sesión para entrar a este panel.</p>
        <button className="boton" style={{ marginTop: "1rem" }} onClick={abrirAuth}>
          Iniciar sesión
        </button>
      </div>
    );
  }

  if (!roles.includes(usuario.rol)) {
    return <p className="mensaje-error">No tienes permisos para ver esta página.</p>;
  }

  return <>{children}</>;
}

export default RutaProtegida;