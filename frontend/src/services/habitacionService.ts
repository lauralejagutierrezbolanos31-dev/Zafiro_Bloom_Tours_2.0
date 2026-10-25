import api from "./api";
import type { Habitacion } from "../types/habitacion";

export const habitacionService = {
  listar: (idHotel: number, fechaInicial?: string, fechaFinal?: string) =>
    api
      .get<Habitacion[]>("/habitaciones/", {
        params: { id_hotel: idHotel, fecha_inicial: fechaInicial, fecha_final: fechaFinal },
      })
      .then((r) => r.data),
};