import api from "./api";
import type { Solicitud } from "../types/panel";

export const adminService = {
  listar: (estado?: string) =>
    api.get<Solicitud[]>("/admin/solicitudes/", { params: { estado } }).then((r) => r.data),
  aprobar: (id: number, idDestino: number | null) =>
    api.put<Solicitud>(`/admin/solicitudes/${id}/aprobar`, { id_destino: idDestino }).then((r) => r.data),
  rechazar: (id: number) =>
    api.put<Solicitud>(`/admin/solicitudes/${id}/rechazar`).then((r) => r.data),
};