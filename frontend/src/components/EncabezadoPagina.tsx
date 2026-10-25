import { Link, useNavigate } from "react-router-dom";

import "./EncabezadoPagina.css";

interface Props {
  titulo: string;
  subtitulo?: string;
}

function EncabezadoPagina({ titulo, subtitulo }: Props) {
  const navigate = useNavigate();

  return (
    <header className="enc-pagina">
      <div className="enc-pagina-nav">
        <button type="button" onClick={() => navigate(-1)}>← Volver</button>
        <Link to="/">🏠 Inicio</Link>
      </div>
      <h1>{titulo}</h1>
      {subtitulo && <p>{subtitulo}</p>}
    </header>
  );
}

export default EncabezadoPagina;