export function moneda(valor: number | string): string {
  return "$" + Number(valor).toLocaleString("es-CO");
}

export function fechaCorta(valor: string): string {
  const [anio, mes, dia] = valor.split("-").map(Number);
  return new Date(anio, mes - 1, dia).toLocaleDateString("es-CO", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

export function calcularNoches(inicio: string, fin: string): number {
  if (!inicio || !fin) return 0;
  const n = Math.round((Date.parse(fin) - Date.parse(inicio)) / 86400000);
  return n > 0 ? n : 0;
}

export function hoy(): string {
  const d = new Date();
  const mes = String(d.getMonth() + 1).padStart(2, "0");
  const dia = String(d.getDate()).padStart(2, "0");
  return `${d.getFullYear()}-${mes}-${dia}`;
}