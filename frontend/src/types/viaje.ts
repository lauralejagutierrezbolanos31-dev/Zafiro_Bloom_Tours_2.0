export interface HabitacionViaje {
  id_habitacion: number;
  nombre_habitacion: string;
  personas_asignadas: number;
  precio_noche: number | string;
}

export interface Viaje {
  id_vp: number;
  id_destino: number;
  nombre_destino: string;
  id_hotel: number;
  nombre_hotel: string;
  fecha_inicial: string;
  fecha_final: string;
  noches: number;
  num_personas: number;
  precio: number | string;
  estado: "reservado" | "cancelado" | "finalizado";
  habitaciones: HabitacionViaje[];
}

export interface CrearViajeDatos {
  id_hotel: number;
  fecha_inicial: string;
  fecha_final: string;
  num_personas: number;
  habitaciones: { id_habitacion: number; personas: number }[];
}

export interface Sugerencia {
  posible: boolean;
  mensaje: string;
  capacidad_disponible: number;
  habitaciones: { id_habitacion: number; nombre: string; capacidad: number; personas: number }[];
}