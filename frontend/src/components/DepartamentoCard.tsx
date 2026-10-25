import { useNavigate } from "react-router-dom";

import type { Depto } from "../types/depto";
import { urlImagen } from "../utils/imagen";
import "./DepartamentoCard.css";

function DepartamentoCard({ depto }: { depto: Depto }) {
  const navigate = useNavigate();

  return (
    <article className="depto-card" onClick={() => navigate(`/destinos/${depto.id_depto}`)}>
      <div className="depto-card-foto">
        <img src={urlImagen(depto.foto_referencia)} alt={depto.nombre} />
        <h3>{depto.nombre}</h3>
      </div>
      <div className="depto-card-cuerpo">
        {depto.descripcion && <p>{depto.descripcion}</p>}
        <button className="boton" type="button">Ver destinos</button>
      </div>
    </article>
  );
}

export default DepartamentoCard;