import api from "./api";
import type { Destino } from "../types/destino";

export const destinoService = {
  listar: (idDepto?: string) =>
    api.get<Destino[]>("/destinos/", { params: { id_depto: idDepto } }).then((r) => r.data),
  obtener: (id: string) => api.get<Destino>(`/destinos/${id}`).then((r) => r.data),
};