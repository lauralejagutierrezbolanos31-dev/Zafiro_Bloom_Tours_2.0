import api from "./api";

export interface SolicitudDatos {
  nombre: string;
  apellidos: string;
  documento: string;
  cargo: string;
  correo: string;
  telefono: string;
  contrasena: string;
  nombre_hotel: string;
  direccion_hotel: string;
  contacto_hotel: string;
  categoria: string;
  descripcion: string;
  politicas: string;
  id_destino: number | null;
}

export const solicitudService = {
  enviar: (datos: SolicitudDatos) =>
    api.post<{ mensaje: string }>("/solicitudes/", datos).then((r) => r.data),
};