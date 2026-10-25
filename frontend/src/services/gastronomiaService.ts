import api from "./api";
import type { Informacion } from "../types/informacion";

export const gastronomiaService = {
  listar: (idDestino: string) =>
    api.get<Informacion[]>("/gastronomia/", { params: { id_destino: idDestino } }).then((r) => r.data),
};