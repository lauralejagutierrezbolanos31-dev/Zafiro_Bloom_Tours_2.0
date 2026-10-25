import type { Informacion } from "../types/informacion";
import "./TarjetaInfo.css";

interface Props {
  titulo: string;
  icono: string;
  color: string;
  items: Informacion[];
}

function TarjetaInfo({ titulo, icono, color, items }: Props) {
  return (
    <article className="tarjeta-info">
      <div className="tarjeta-info-icono" style={{ background: color }}>{icono}</div>
      <div className="tarjeta-info-texto">
        <h2>{titulo}</h2>
        {items.length === 0 && <p>Sin información registrada.</p>}
        {items.map((item, i) => (
          <div key={i}>
            <p>{item.descripcion}</p>
            {item.contacto && <p className="tarjeta-info-contacto">📞 Contacto: {item.contacto}</p>}
          </div>
        ))}
      </div>
    </article>
  );
}

export default TarjetaInfo;