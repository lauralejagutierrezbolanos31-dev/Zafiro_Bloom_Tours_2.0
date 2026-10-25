import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";

import DestinoCard from "../components/DestinoCard";
import { deptoService } from "../services/deptoService";
import { destinoService } from "../services/destinoService";
import type { Depto } from "../types/depto";
import type { Destino } from "../types/destino";
import { urlImagen } from "../utils/imagen";
import "./DestinosPorDepto.css";

function DestinosPorDepto() {
  const { idDepto } = useParams<{ idDepto: string }>();
  const [depto, setDepto] = useState<Depto | null>(null);
  const [destinos, setDestinos] = useState<Destino[]>([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!idDepto) return;
    setCargando(true);
    Promise.all([deptoService.obtener(idDepto), destinoService.listar(idDepto)])
      .then(([d, lista]) => {
        setDepto(d);
        setDestinos(lista);
      })
      .catch(() => setError("No se pudo cargar el departamento."))
      .finally(() => setCargando(false));
  }, [idDepto]);

  if (cargando) return <p className="mensaje-carga">Cargando...</p>;
  if (error || !depto) return <p className="mensaje-error">{error || "Departamento no encontrado"}</p>;

  return (
    <>
      <div
        className="depto-banner"
        style={{ backgroundImage: `url("${urlImagen(depto.foto_referencia)}")` }}
      >
        <h1>{depto.nombre}</h1>
      </div>

      {depto.descripcion && <p className="depto-descripcion">{depto.descripcion}</p>}

      <section className="depto-destinos">
        <h2>Destinos en {depto.nombre}</h2>
        {destinos.length === 0 && <p>Aún no hay destinos registrados en este departamento.</p>}
        <div className="depto-destinos-lista">
          {destinos.map((d) => (
            <DestinoCard key={d.id_destino} destino={d} />
          ))}
        </div>
      </section>
    </>
  );
}

export default DestinosPorDepto;