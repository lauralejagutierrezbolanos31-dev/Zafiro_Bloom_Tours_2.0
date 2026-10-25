import type { Informacion } from "../types/informacion";
import { urlImagen } from "../utils/imagen";
import "./CarruselSeccion.css";

interface Props {
  titulo: string;
  items: Informacion[];
}

function CarruselSeccion({ titulo, items }: Props) {
  if (items.length === 0) return null;

  return (
    <section className="carrusel-seccion">
      <h2>{titulo}</h2>
      <div className="carrusel">
        {items.map((item, i) => (
          <article key={i} className="carrusel-item">
            {item.foto_referencia && <img src={urlImagen(item.foto_referencia)} alt={titulo} />}
            <p>{item.descripcion}</p>
          </article>
        ))}
      </div>
    </section>
  );
}

export default CarruselSeccion;