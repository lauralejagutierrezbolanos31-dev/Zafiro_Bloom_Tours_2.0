import api from "./api";
import type { Usuario } from "../types/usuario";

export type EdicionUsuario = Partial<
  Pick<Usuario, "nombre" | "apellidos" | "ciudad" | "direccion" | "telefono">
>;

export const usuarioService = {
  editar: (datos: EdicionUsuario) => api.put<Usuario>("/usuarios/me", datos).then((r) => r.data),
  eliminar: (contrasena: string) => api.delete("/usuarios/me", { data: { contrasena } }),
};