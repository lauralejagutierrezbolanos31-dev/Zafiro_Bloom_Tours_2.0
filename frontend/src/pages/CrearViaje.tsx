import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";

import ModalHabitaciones from "../components/ModalHabitaciones";
import TarjetaHotel from "../components/TarjetaHotel";
import TarjetaInfo from "../components/TarjetaInfo";
import { actividadService } from "../services/actividadService";
import { gastronomiaService } from "../services/gastronomiaService";
import { hotelService } from "../services/hotelService";
import { transporteService } from "../services/transporteService";
import type { Hotel } from "../types/hotel";
import type { Informacion } from "../types/informacion";
import "./CrearViaje.css";

function CrearViaje() {
  const { idDestino } = useParams<{ idDestino: string }>();
  const navigate = useNavigate();

  const [gastronomia, setGastronomia] = useState<Informacion[]>([]);
  const [transporte, setTransporte] = useState<Informacion[]>([]);
  const [actividades, setActividades] = useState<Informacion[]>([]);
  const [hoteles, setHoteles] = useState<Hotel[]>([]);
  const [hotelElegido, setHotelElegido] = useState<Hotel | null>(null);
  const [error, setError] = useState("");

  function cargarHoteles() {
    if (idDestino) hotelService.listar(idDestino).then(setHoteles);
  }

  useEffect(() => {
    if (!idDestino) return;
    Promise.all([
      gastronomiaService.listar(idDestino),
      transporteService.listar(idDestino),
      actividadService.listar(idDestino),
      hotelService.listar(idDestino),
    ])
      .then(([g, t, a, h]) => {
        setGastronomia(g);
        setTransporte(t);
        setActividades(a);
        setHoteles(h);
      })
      .catch(() => setError("No se pudo cargar la información del destino."));
  }, [idDestino]);

  return (
    <div className="crear-viaje">
      <header className="crear-viaje-encabezado">
        <h1>Crea tu viaje personalizado</h1>
        <p>
          Descubre todo lo que necesitas para disfrutar de tu destino. Gastronomía, transporte,
          actividades y hospedaje en un solo lugar.
        </p>
      </header>

      {error && <p className="mensaje-error">{error}</p>}

      <section className="crear-viaje-info">
        <TarjetaInfo titulo="Gastronomía" icono="🍴" color="#f7a623" items={gastronomia} />
        <TarjetaInfo titulo="Transporte" icono="🚌" color="#2bb673" items={transporte} />
        <TarjetaInfo titulo="Actividades" icono="🥾" color="#2788d8" items={actividades} />
      </section>

      <section>
        <h2 className="crear-viaje-subtitulo">Escoge tu hotel</h2>
        {hoteles.length === 0 && <p>Aún no hay hoteles registrados en este destino.</p>}
        <div className="crear-viaje-hoteles">
          {hoteles.map((h) => (
            <TarjetaHotel key={h.id_hotel} hotel={h} onElegir={setHotelElegido} />
          ))}
        </div>
      </section>

      {hotelElegido && (
        <ModalHabitaciones
          hotel={hotelElegido}
          onCerrar={() => setHotelElegido(null)}
          onReservado={() => {
            setHotelElegido(null);
            cargarHoteles();
            navigate("/mis-viajes");
          }}
        />
      )}
    </div>
  );
}

export default CrearViaje;