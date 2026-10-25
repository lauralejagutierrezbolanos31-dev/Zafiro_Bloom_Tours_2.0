import { useEffect, useState } from "react";

import DepartamentoCard from "../components/DepartamentoCard";
import { deptoService } from "../services/deptoService";
import type { Depto } from "../types/depto";
import "./Home.css";

function Home() {
  const [deptos, setDeptos] = useState<Depto[]>([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    deptoService
      .listar()
      .then(setDeptos)
      .catch(() => setError("No se pudieron cargar los departamentos."))
      .finally(() => setCargando(false));
  }, []);

  return (
    <>
      <section className="hero">
        <h1>Conecta con nuevos lugares</h1>
        <p>
          ✈️ Bienvenidos a Zafiro Bloom Tours. Descubre destinos increíbles y vive experiencias
          inolvidables. Encuentra los mejores paquetes turísticos para disfrutar tus vacaciones
          con comodidad, seguridad y los mejores precios.
        </p>
      </section>

      <section className="home-deptos">
        <h2>Explora por departamento</h2>
        {cargando && <p className="mensaje-carga">Cargando departamentos...</p>}
        {error && <p className="mensaje-error">{error}</p>}
        <div className="home-deptos-lista">
          {deptos.map((d) => (
            <DepartamentoCard key={d.id_depto} depto={d} />
          ))}
        </div>
      </section>
    </>
  );
}

export default Home;