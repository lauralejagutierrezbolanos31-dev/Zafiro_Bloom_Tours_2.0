export interface Habitacion {
  id_habitacion: number;
  id_hotel: number;
  nombre: string;
  descripcion: string | null;
  tipo_cama: string | null;
  capacidad: number;
  precio: number | string;
  foto_referencia: string | null;
  disponible: boolean;
}