import { useNavigate } from "react-router-dom";

import "./HazParte.css";

function HazParte() {
  const navigate = useNavigate();

  return (
    <div className="haz-parte">
      <header className="haz-parte-encabezado">
        <h1>Haz parte de Zafiro Bloom Tours 🌿</h1>
        <p>
          Nuestra plataforma nace con un propósito claro: impulsar la economía local y dar
          visibilidad a los pueblos mágicos de nuestra región. Conectamos a viajeros apasionados con
          la auténtica cultura, hotelería y tradiciones locales.
        </p>
      </header>

      <section className="haz-parte-roles">
        <article className="haz-parte-rol">
          <h3 className="rol-admin">🏨 Administrador (dueño de hotel)</h3>
          <p>
            ¿Tienes un hotel o alojamiento en un pueblo? Únete para gestionar tu propio hospedaje,
            agregar tus habitaciones, actualizar tarifas y registrar nuevos destinos si aún no
            figuran en el sistema.
          </p>
        </article>
        <article className="haz-parte-rol">
          <h3 className="rol-super">⚡ Super administrador</h3>
          <p>
            Encargado de validar y aprobar las solicitudes de los nuevos administradores,
            asegurando la calidad y autenticidad de la oferta turística en cada municipio.
          </p>
        </article>
      </section>

      <section className="haz-parte-cta">
        <h2>¿Eres dueño de un hotel o quieres registrar un destino?</h2>
        <p>
          Envía tu solicitud de registro. Nuestro equipo de Super Administración evaluará tu
          petición para otorgarte el rol de <strong>Administrador</strong> y habilitar tu panel de
          control personalizado.
        </p>
        <button className="boton" onClick={() => navigate("/solicitar-acceso")}>
          Solicitar acceso como administrador
        </button>
      </section>
    </div>
  );
}

export default HazParte;