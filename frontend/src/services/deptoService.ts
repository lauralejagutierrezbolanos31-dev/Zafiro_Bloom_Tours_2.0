import api from "./api";
import type { Depto } from "../types/depto";

export const deptoService = {
  listar: () => api.get<Depto[]>("/deptos/").then((r) => r.data),
  obtener: (id: string) => api.get<Depto>(`/deptos/${id}`).then((r) => r.data),
};