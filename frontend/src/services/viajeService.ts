import api from "./api";
import type { CrearViajeDatos, Sugerencia, Viaje } from "../types/viaje";

export const viajeService = {
  crear: (datos: CrearViajeDatos) => api.post<Viaje>("/viajes/", datos).then((r) => r.data),
  misViajes: () => api.get<Viaje[]>("/viajes/mis-viajes").then((r) => r.data),
  cancelar: (id: number) => api.put<Viaje>(`/viajes/${id}/cancelar`).then((r) => r.data),
  sugerir: (datos: Omit<CrearViajeDatos, "habitaciones">) =>
    api.post<Sugerencia>("/viajes/sugerir", datos).then((r) => r.data),
};