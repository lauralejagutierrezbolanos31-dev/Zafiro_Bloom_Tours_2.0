import api from "./api";
import type { Informacion } from "../types/informacion";

export const actividadService = {
  listar: (idDestino: string) =>
    api.get<Informacion[]>("/actividades/", { params: { id_destino: idDestino } }).then((r) => r.data),
};