export interface Feria {
  id_feria: number;
  nombre: string;
  tipo: "feria" | "oferta";
  descripcion: string | null;
  foto_referencia: string | null;
  fecha_inicio: string | null;
  fecha_fin: string | null;
  descuento_porcentaje: number | string | null;
  nombre_depto: string | null;
  nombre_destino: string | null;
}

export interface FeriaAdmin extends Feria {
  id_depto: number | null;
  id_destino: number | null;
  activo: boolean;
}

export interface FeriaGuardar {
  nombre: string;
  tipo: "feria" | "oferta";
  descripcion: string | null;
  foto_referencia: string | null;
  id_depto: number | null;
  id_destino: number | null;
  fecha_inicio: string | null;
  fecha_fin: string | null;
  descuento_porcentaje: number | null;
  activo: boolean;
}