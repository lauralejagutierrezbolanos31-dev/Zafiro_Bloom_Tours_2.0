import api from "./api";
import type { Depto } from "../types/depto";
import type { Destino } from "../types/destino";

export interface ResultadoBusqueda {
  departamentos: Depto[];
  destinos: Destino[];
}

export const busquedaService = {
  buscar: (q: string) =>
    api.get<ResultadoBusqueda>("/buscar/", { params: { q } }).then((r) => r.data),
};