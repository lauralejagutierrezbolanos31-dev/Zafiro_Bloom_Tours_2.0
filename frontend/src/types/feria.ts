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