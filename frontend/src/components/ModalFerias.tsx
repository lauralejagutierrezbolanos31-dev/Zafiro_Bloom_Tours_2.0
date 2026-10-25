import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

import { busquedaService, type ResultadoBusqueda } from "../services/busquedaService";
import { feriaService } from "../services/feriaService";
import type { Feria } from "../types/feria";
import { urlImagen } from "../utils/imagen";
import "./ModalFerias.css";

export type ModoModal = "feria" | "oferta" | "busqueda";

interface Props {
  modo: ModoModal;
  termino?: string;
  onCerrar: () => void;
}

const TITULOS: Record<ModoModal, string> = {
  feria: "Ferias y Fiestas del Mes",
  oferta: "Ofertas Relámpago",
  busqueda: "Resultados de la búsqueda",
};

function fecha(valor: string | null) {
  if (!valor) return null;
  const [anio, mes, dia] = valor.split("-").map(Number);
  return new Date(anio, mes - 1, dia).toLocaleDateString("es-CO", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function ModalFerias({ modo, termino, onCerrar }: Props) {
  const navigate = useNavigate();
  const [ferias, setFerias] = useState<Feria[]>([]);
  const [resultado, setResultado] = useState<ResultadoBusqueda>({ departamentos: [], destinos: [] });
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    setCargando(true);
    setError("");
    const peticion =
      modo === "busqueda"
        ? busquedaService.buscar(termino ?? "").then(setResultado)
        : feriaService.listar(modo).then(setFerias);

    peticion
      .catch(() => setError("No se pudieron cargar los resultados. Intenta de nuevo."))
      .finally(() => setCargando(false));
  }, [modo, termino]);

  function ir(ruta: string) {
    onCerrar();
    navigate(ruta);
  }

  const vacio =
    !cargando &&
    !error &&
    ferias.length === 0 &&
    resultado.departamentos.length === 0 &&
    resultado.destinos.length === 0;

  return (
    <div className="modal-fondo" onClick={onCerrar}>
      <div className="modal-caja" onClick={(e) => e.stopPropagation()}>
        <div className="modal-encabezado">
          <h2>
            {TITULOS[modo]}
            {modo === "busqueda" && termino ? `: "${termino}"` : ""}
          </h2>
          <button className="modal-cerrar" onClick={onCerrar} aria-label="Cerrar">✕</button>
        </div>

        <div className="modal-cuerpo">
          {cargando && <p className="mensaje-carga">Cargando...</p>}
          {error && <p className="mensaje-error">{error}</p>}
          {vacio && (
            <p className="mensaje-carga">
              {modo === "busqueda"
                ? "No encontramos departamentos ni municipios con ese nombre."
                : "No hay nada por ahora. ¡Vuelve pronto!"}
            </p>
          )}

          {ferias.length > 0 && (
            <div className="modal-lista">
              {ferias.map((f) => (
                <article key={f.id_feria} className={`modal-tarjeta modal-tarjeta-${f.tipo}`}>
                  {f.foto_referencia && <img src={urlImagen(f.foto_referencia)} alt={f.nombre} />}
                  <div className="modal-tarjeta-cuerpo">
                    <div className="modal-tarjeta-titulo">
                      <h3>{f.nombre}</h3>
                      {f.tipo === "oferta" && f.descuento_porcentaje && (
                        <span className="etiqueta-descuento">-{Number(f.descuento_porcentaje)}%</span>
                      )}
                    </div>
                    {(f.nombre_destino || f.nombre_depto) && (
                      <p className="modal-ubicacion">
                        📍 {[f.nombre_destino, f.nombre_depto].filter(Boolean).join(", ")}
                      </p>
                    )}
                    {f.descripcion && <p>{f.descripcion}</p>}
                    {(f.fecha_inicio || f.fecha_fin) && (
                      <p className="modal-fechas">
                        🗓️ {fecha(f.fecha_inicio) ?? "Por confirmar"}
                        {f.fecha_fin ? ` – ${fecha(f.fecha_fin)}` : ""}
                      </p>
                    )}
                  </div>
                </article>
              ))}
            </div>
          )}

          {resultado.departamentos.length > 0 && (
            <>
              <h3 className="modal-subtitulo">Departamentos</h3>
              <div className="modal-lista">
                {resultado.departamentos.map((d) => (
                  <article
                    key={d.id_depto}
                    className="modal-tarjeta modal-tarjeta-click"
                    onClick={() => ir(`/destinos/${d.id_depto}`)}
                  >
                    {d.foto_referencia && <img src={urlImagen(d.foto_referencia)} alt={d.nombre} />}
                    <div className="modal-tarjeta-cuerpo">
                      <h3>{d.nombre}</h3>
                      {d.descripcion && <p>{d.descripcion}</p>}
                    </div>
                  </article>
                ))}
              </div>
            </>
          )}

          {resultado.destinos.length > 0 && (
            <>
              <h3 className="modal-subtitulo">Municipios y destinos</h3>
              <div className="modal-lista">
                {resultado.destinos.map((d) => (
                  <article
                    key={d.id_destino}
                    className="modal-tarjeta modal-tarjeta-click"
                    onClick={() => ir(`/destino/${d.id_destino}`)}
                  >
                    {d.foto_referencia && <img src={urlImagen(d.foto_referencia)} alt={d.nombre} />}
                    <div className="modal-tarjeta-cuerpo">
                      <h3>{d.nombre}</h3>
                      {d.generalidades && <p>{d.generalidades}</p>}
                    </div>
                  </article>
                ))}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default ModalFerias;