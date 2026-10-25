import { isAxiosError } from "axios";

export function mensajeError(err: unknown, porDefecto: string): string {
  if (isAxiosError(err)) {
    const detalle = err.response?.data?.detail;
    if (typeof detalle === "string") return detalle;
    if (err.response?.status === 422) {
      return "Revisa los datos ingresados (la contraseña debe tener mínimo 8 caracteres).";
    }
  }
  return porDefecto;
}