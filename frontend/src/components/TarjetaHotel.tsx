import type { Hotel } from "../types/hotel";
import { moneda } from "../utils/formato";
import { urlImagen } from "../utils/imagen";
import "./TarjetaHotel.css";

interface Props {
  hotel: Hotel;
  onElegir: (hotel: Hotel) => void;
}

function TarjetaHotel({ hotel, onElegir }: Props) {
  const ocupacion = Number(hotel.porcentaje_ocupacion);
  const lleno = ocupacion >= 100;

  return (
    <article className={`tarjeta-hotel ${lleno ? "tarjeta-hotel-lleno" : ""}`}>
      {hotel.foto_referencia ? (
        <img src={urlImagen(hotel.foto_referencia)} alt={hotel.nombre} />
      ) : (
        <div className="tarjeta-hotel-sinfoto">Sin imagen</div>
      )}

      <div className="tarjeta-hotel-cuerpo">
        <h3>{hotel.nombre}</h3>
        {hotel.direccion && <p className="tarjeta-hotel-dir">📍 {hotel.direccion}</p>}
        {hotel.descripcion && <p className="tarjeta-hotel-desc">{hotel.descripcion}</p>}

        <div className="tarjeta-hotel-datos">
          <span>Precio promedio</span>
          <strong>{moneda(hotel.precio_promedio)}</strong>
        </div>
        <div className="tarjeta-hotel-datos tarjeta-hotel-ocupacion">
          <span>Ocupación</span>
          <strong>{ocupacion}%</strong>
        </div>

        <button className="boton" type="button" disabled={lleno} onClick={() => onElegir(hotel)}>
          {lleno ? "Hotel completo" : "Ver habitaciones"}
        </button>
      </div>
    </article>
  );
}

export default TarjetaHotel;