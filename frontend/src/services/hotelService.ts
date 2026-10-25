import api from "./api";
import type { Hotel } from "../types/hotel";

export const hotelService = {
  listar: (idDestino: string) =>
    api.get<Hotel[]>("/hoteles/", { params: { id_destino: idDestino } }).then((r) => r.data),
};