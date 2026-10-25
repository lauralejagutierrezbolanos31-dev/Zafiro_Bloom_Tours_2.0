export interface Hotel {
  id_hotel: number;
  id_destino: number;
  nombre: string;
  foto_referencia: string | null;
  direccion: string | null;
  descripcion: string | null;
  contacto: string | null;
  categoria: string | null;
  total_habitaciones: number;
  habitaciones_ocupadas: number;
  precio_promedio: number | string;
  porcentaje_ocupacion: number | string;
}
