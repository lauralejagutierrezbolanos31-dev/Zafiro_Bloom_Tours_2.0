import { useEffect, useState } from "react";

import { adminService } from "../services/adminService";
import { destinoService } from "../services/destinoService";
import type { Destino } from "../types/destino";
import type { Solicitud } from "../types/panel";
import { mensajeError } from "../utils/errores";
import "./PanelSolicitudes.css";

function PanelSolicitudes() {
  const [solicitudes, setSolicitudes] = useState<Solicitud[]>([]);
  const [destinos, setDestinos] = useState<Destino[]>([]);
  const [destinoElegido, setDestinoElegido] = useState<Record<number, string>>({});
  const [filtro, setFiltro] = useState<"pendiente" | "aprobada" | "rechazada">("pendiente");
  const [error, setError] = useState("");
  const [aviso, setAviso] = useState("");

  useEffect(() => {
    destinoService.listar().then(setDestinos).catch(() => setDestinos([]));
  }, []);

  useEffect(() => {
    adminService
      .listar(filtro)
      .then(setSolicitudes)
      .catch((e) => setError(mensajeError(e, "No se pudieron cargar las solicitudes.")));
  }, [filtro]);

  async function resolver(s: Solicitud, accion: "aprobar" | "rechazar") {
    setError("");
    setAviso("");
    try {
      if (accion === "aprobar") {
        const idDestino = destinoElegido[s.id_solicitud]
          ? Number(destinoElegido[s.id_solicitud])
          : s.id_destino;
        await adminService.aprobar(s.id_solicitud, idDestino);
        setAviso(`Solicitud de ${s.nombre_hotel} aprobada. Ya puede iniciar sesión como administrador.`);
      } else {
        if (!window.confirm("¿Rechazar esta solicitud?")) return;
        await adminService.rechazar(s.id_solicitud);
        setAviso("Solicitud rechazada.");
      }
      setSolicitudes((lista) => lista.filter((x) => x.id_solicitud !== s.id_solicitud));
    } catch (e) {
      setError(mensajeError(e, "No se pudo procesar la solicitud."));
    }
  }

  return (
    <div className="panel-sol">
      <h1>Solicitudes de administradores</h1>

      <div className="panel-sol-filtros">
        {(["pendiente", "aprobada", "rechazada"] as const).map((f) => (
          <button
            key={f}
            className={filtro === f ? "filtro-activo" : ""}
            onClick={() => {
              setFiltro(f);
              setAviso("");
            }}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}s
          </button>
        ))}
      </div>

      {aviso && <p className="panel-sol-ok">{aviso}</p>}
      {error && <p className="mensaje-error">{error}</p>}
      {solicitudes.length === 0 && <p className="mensaje-carga">No hay solicitudes {filtro}s.</p>}

      <div className="panel-sol-lista">
        {solicitudes.map((s) => (
          <article key={s.id_solicitud} className="panel-sol-item">
            <h2>{s.nombre_hotel}</h2>
            <p className="panel-sol-cat">{s.categoria}</p>
            <p><strong>Solicitante:</strong> {s.nombre} {s.apellidos} · {s.cargo}</p>
            <p><strong>Documento:</strong> {s.documento} · <strong>Correo:</strong> {s.correo}</p>
            <p><strong>Teléfono:</strong> {s.telefono || "—"} · <strong>Hotel:</strong> {s.contacto_hotel}</p>
            <p><strong>Dirección:</strong> {s.direccion_hotel}</p>
            <p>{s.descripcion}</p>
            <p><em>Políticas: {s.politicas}</em></p>

            {s.estado === "pendiente" && (
              <div className="panel-sol-acciones">
                <select
                  value={destinoElegido[s.id_solicitud] ?? (s.id_destino ? String(s.id_destino) : "")}
                  onChange={(e) =>
                    setDestinoElegido((d) => ({ ...d, [s.id_solicitud]: e.target.value }))
                  }
                >
                  <option value="">Asignar destino...</option>
                  {destinos.map((d) => (
                    <option key={d.id_destino} value={d.id_destino}>{d.nombre}</option>
                  ))}
                </select>
                <button className="boton" onClick={() => resolver(s, "aprobar")}>Aprobar</button>
                <button className="panel-sol-rechazar" onClick={() => resolver(s, "rechazar")}>
                  Rechazar
                </button>
              </div>
            )}
          </article>
        ))}
      </div>
    </div>
  );
}

export default PanelSolicitudes;