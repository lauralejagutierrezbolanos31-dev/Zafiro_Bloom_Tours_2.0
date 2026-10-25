import api from "./api";
import type { Feria } from "../types/feria";

export const feriaService = {
  listar: (tipo: "feria" | "oferta") =>
    api.get<Feria[]>("/ferias/", { params: { tipo } }).then((r) => r.data),
};