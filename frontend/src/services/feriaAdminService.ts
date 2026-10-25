import api from "./api";
import type { FeriaAdmin, FeriaGuardar } from "../types/feria";

export const feriaAdminService = {
  listar: () => api.get<FeriaAdmin[]>("/admin/ferias/").then((r) => r.data),
  crear: (datos: FeriaGuardar) =>
    api.post<FeriaAdmin>("/admin/ferias/", datos).then((r) => r.data),
  actualizar: (id: number, datos: FeriaGuardar) =>
    api.put<FeriaAdmin>(`/admin/ferias/${id}`, datos).then((r) => r.data),
  eliminar: (id: number) => api.delete(`/admin/ferias/${id}`),
};