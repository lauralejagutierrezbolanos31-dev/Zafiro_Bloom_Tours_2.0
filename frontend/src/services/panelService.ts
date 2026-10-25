import api from "./api";
import type { HabitacionForm, HabitacionPanel, HotelPanel, ReservaHotel } from "../types/panel";

export const panelService = {
  hoteles: () => api.get<HotelPanel[]>("/panel/hoteles").then((r) => r.data),
  habitaciones: (idHotel: number) =>
    api.get<HabitacionPanel[]>(`/panel/hoteles/${idHotel}/habitaciones`).then((r) => r.data),
  crearHabitacion: (idHotel: number, datos: HabitacionForm) =>
    api.post<HabitacionPanel>(`/panel/hoteles/${idHotel}/habitaciones`, normalizar(datos)).then((r) => r.data),
  editarHabitacion: (id: number, datos: Partial<HabitacionForm> & { activa?: boolean }) =>
    api.put<HabitacionPanel>(`/panel/habitaciones/${id}`, datos).then((r) => r.data),
  quitarHabitacion: (id: number) => api.delete(`/panel/habitaciones/${id}`),
  reservas: (idHotel: number) =>
    api.get<ReservaHotel[]>(`/panel/hoteles/${idHotel}/reservas`).then((r) => r.data),
};

function normalizar(d: HabitacionForm) {
  return { ...d, tipo_cama: d.tipo_cama || null, foto_referencia: d.foto_referencia || null };
}