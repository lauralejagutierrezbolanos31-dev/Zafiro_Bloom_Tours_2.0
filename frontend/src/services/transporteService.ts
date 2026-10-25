import api from "./api";
import type { Informacion } from "../types/informacion";

export const transporteService = {
  listar: (idDestino: string) =>
    api.get<Informacion[]>("/transporte/", { params: { id_destino: idDestino } }).then((r) => r.data),
};