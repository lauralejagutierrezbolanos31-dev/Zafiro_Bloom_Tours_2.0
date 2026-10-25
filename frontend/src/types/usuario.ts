export interface Usuario {
  id_usuario: number;
  nombre: string;
  apellidos: string | null;
  ciudad: string | null;
  direccion: string | null;
  correo: string;
  telefono: string | null;
  rol: "usuario" | "admin_hotel" | "super_admin";
}

export interface RegistroDatos {
  nombre: string;
  apellidos?: string;
  ciudad?: string;
  direccion?: string;
  telefono?: string;
  correo: string;
  contrasena: string;
}

export interface RespuestaAuth {
  access_token: string;
  token_type: string;
  usuario: Usuario;
}