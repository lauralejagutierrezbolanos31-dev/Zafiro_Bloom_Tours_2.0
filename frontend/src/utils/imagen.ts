export function urlImagen(ruta: string | null | undefined): string {
  return ruta ? encodeURI(ruta) : "";
}