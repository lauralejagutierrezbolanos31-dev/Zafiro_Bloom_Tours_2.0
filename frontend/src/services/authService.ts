import api from "./api";
import type { RegistroDatos, RespuestaAuth } from "../types/usuario";

export const authService = {
  login: (correo: string, contrasena: string) =>
    api.post<RespuestaAuth>("/usuarios/login", { correo, contrasena }).then((r) => r.data),
  registro: (datos: RegistroDatos) =>
    api.post<RespuestaAuth>("/usuarios/registro", datos).then((r) => r.data),
};