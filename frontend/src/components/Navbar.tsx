import { useState, type FormEvent } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";

import logo from "../assets/logo.png";
import { useAuth } from "../context/AuthContext";
import ModalFerias, { type ModoModal } from "./ModalFerias";
import "./Navbar.css";

function Navbar() {
  const navigate = useNavigate();
  const { pathname } = useLocation();
  const { usuario, abrirAuth, cerrarSesion } = useAuth();
  const enInicio = pathname === "/";

  const [busqueda, setBusqueda] = useState("");
  const [terminoActivo, setTerminoActivo] = useState("");
  const [modal, setModal] = useState<ModoModal | null>(null);

  function buscar(e: FormEvent) {
    e.preventDefault();
    if (!busqueda.trim()) return;
    setTerminoActivo(busqueda.trim());
    setModal("busqueda");
  }

  return (
    <>
      <header className="cabecera">
        <nav className="navbar">
          <Link to="/" className="navbar-marca">
            <img src={logo} alt="Zafiro Bloom Tours" className="navbar-logo" />
            <span className="navbar-titulo">Zafiro Bloom Tours</span>
          </Link>

          {!enInicio && (
            <Link to="/" className="navbar-boton navbar-boton-inicio">🏠 Inicio</Link>
          )}

          {enInicio && (
            <div className="navbar-botones">
              <button className="navbar-boton navbar-boton-ferias" onClick={() => setModal("feria")}>
                📅 Ferias y Fiestas del Mes
              </button>
              <button className="navbar-boton navbar-boton-ofertas" onClick={() => setModal("oferta")}>
                ⚡ Ofertas Relámpago
              </button>
              <button className="navbar-boton navbar-boton-parte" onClick={() => navigate("/haz-parte")}>
                🌿 Haz parte de Zafiro Bloom Tours
              </button>
            </div>
          )}

          <div className="navbar-sesion">
            {usuario ? (
              <>
                <span className="navbar-saludo">Hola, {usuario.nombre}</span>

                {usuario.rol === "super_admin" && (
                  <>
                    <Link to="/panel/solicitudes" className="navbar-enlace">Solicitudes</Link>
                    <Link to="/panel/ferias" className="navbar-enlace">Ferias</Link>
                  </>
                )}

                {(usuario.rol === "admin_hotel" || usuario.rol === "super_admin") && (
                  <Link to="/panel/hotel" className="navbar-enlace">Mi hotel</Link>
                )}

                <Link to="/mis-viajes" className="navbar-enlace">Mis viajes</Link>
                <Link to="/cuenta" className="navbar-enlace">Mi cuenta</Link>
                <button
                  className="navbar-enlace"
                  onClick={() => {
                    cerrarSesion();
                    navigate("/");
                  }}
                >
                  Cerrar sesión
                </button>
              </>
            ) : (
              <button className="navbar-enlace" onClick={abrirAuth}>
                Iniciar Sesión / Registrarse
              </button>
            )}
          </div>
        </nav>

        {enInicio && (
          <form className="buscador-contenedor" onSubmit={buscar}>
            <div className="buscador">
              <span>🔍</span>
              <input
                type="text"
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
                placeholder="Buscar por Departamento o Municipio (ej. Boyacá, Monguí)"
              />
              <button type="submit" className="boton buscador-boton">Buscar</button>
            </div>
          </form>
        )}
      </header>

      {modal && (
        <ModalFerias
          modo={modal}
          termino={modal === "busqueda" ? terminoActivo : undefined}
          onCerrar={() => setModal(null)}
        />
      )}
    </>
  );
}

export default Navbar;