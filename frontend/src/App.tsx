import { Route, Routes } from "react-router-dom";

import AuthModal from "./components/AuthModal";
import Footer from "./components/Footer";
import Navbar from "./components/Navbar";
import Cuenta from "./pages/Cuenta";
import CrearViaje from "./pages/CrearViaje";
import DetalleDestino from "./pages/DetalleDestino";
import DestinosPorDepto from "./pages/DestinosPorDepto";
import HazParte from "./pages/HazParte";
import Home from "./pages/Home";
import MisViajes from "./pages/MisViajes";
import SolicitarAcceso from "./pages/SolicitarAcceso";
import RutaProtegida from "./components/RutaProtegida";
import PanelHotel from "./pages/PanelHotel";
import PanelSolicitudes from "./pages/PanelSolicitudes";
import PanelFerias from "./pages/PanelFerias";

function App() {
  return (
    <>
      <Navbar />
      <main className="contenido-principal">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/destinos/:idDepto" element={<DestinosPorDepto />} />
          <Route path="/destino/:idDestino" element={<DetalleDestino />} />
          <Route path="/crear-viaje/:idDestino" element={<CrearViaje />} />
          <Route path="/mis-viajes" element={<MisViajes />} />
          <Route path="/cuenta" element={<Cuenta />} />
          <Route path="/haz-parte" element={<HazParte />} />
          <Route path="/solicitar-acceso" element={<SolicitarAcceso />} />
          <Route path="/panel/solicitudes" element={<RutaProtegida roles={["super_admin"]}><PanelSolicitudes /></RutaProtegida>} />
          <Route path="/panel/hotel" element={<RutaProtegida roles={["admin_hotel", "super_admin"]}><PanelHotel /></RutaProtegida>} />
          <Route path="/panel/ferias" element={<RutaProtegida roles={["super_admin"]}><PanelFerias /></RutaProtegida>} />
        </Routes>
      </main>
      <Footer />
      <AuthModal />
    </>
  );
}

export default App;