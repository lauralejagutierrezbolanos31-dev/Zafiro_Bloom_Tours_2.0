--
-- PostgreSQL database dump
--

\restrict glS1sYZFCs2N86QXs1LsgzwnbHkZEWGwsSVr7Zvx8qBjeH58x0vAiLvhXls75G2

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: estado_solicitud; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_solicitud AS ENUM (
    'pendiente',
    'aprobada',
    'rechazada'
);


--
-- Name: estado_viaje; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_viaje AS ENUM (
    'reservado',
    'cancelado',
    'finalizado'
);


--
-- Name: rol_usuario; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.rol_usuario AS ENUM (
    'usuario',
    'admin_hotel',
    'super_admin'
);


--
-- Name: tipo_feria; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_feria AS ENUM (
    'feria',
    'oferta'
);


--
-- Name: sincronizar_habitaciones_viaje(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sincronizar_habitaciones_viaje() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE viaje_habitacion
       SET activa = (NEW.estado = 'reservado')
     WHERE id_vp = NEW.id_vp;
    RETURN NEW;
END;
$$;


--
-- Name: validar_capacidad_habitacion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validar_capacidad_habitacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_cap INT;
BEGIN
    SELECT capacidad INTO v_cap FROM habitacion WHERE id_habitacion = NEW.id_habitacion;
    IF NEW.personas_asignadas > v_cap THEN
        RAISE EXCEPTION 'La habitaciÃ³n % admite mÃ¡ximo % personas', NEW.id_habitacion, v_cap;
    END IF;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actividades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actividades (
    id_actividades integer NOT NULL,
    id_destino integer NOT NULL,
    descripcion text NOT NULL,
    contacto character varying(30),
    foto_referencia character varying(255)
);


--
-- Name: actividades_id_actividades_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actividades_id_actividades_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actividades_id_actividades_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actividades_id_actividades_seq OWNED BY public.actividades.id_actividades;


--
-- Name: deptos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deptos (
    id_depto integer NOT NULL,
    nombre character varying(100) NOT NULL,
    foto_referencia character varying(255),
    descripcion text
);


--
-- Name: deptos_id_depto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deptos_id_depto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deptos_id_depto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deptos_id_depto_seq OWNED BY public.deptos.id_depto;


--
-- Name: destinos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.destinos (
    id_destino integer NOT NULL,
    id_depto integer NOT NULL,
    nombre character varying(150) NOT NULL,
    foto_referencia character varying(255),
    clima text,
    generalidades text,
    fecha_registro timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: destinos_id_destino_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.destinos_id_destino_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: destinos_id_destino_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.destinos_id_destino_seq OWNED BY public.destinos.id_destino;


--
-- Name: ferias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ferias (
    id_feria integer NOT NULL,
    id_depto integer,
    id_destino integer,
    nombre character varying(150) NOT NULL,
    tipo public.tipo_feria NOT NULL,
    descripcion text,
    foto_referencia character varying(255),
    fecha_inicio date,
    fecha_fin date,
    descuento_porcentaje numeric(5,2),
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT ferias_descuento_porcentaje_check CHECK (((descuento_porcentaje >= (0)::numeric) AND (descuento_porcentaje <= (100)::numeric)))
);


--
-- Name: ferias_id_feria_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ferias_id_feria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ferias_id_feria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ferias_id_feria_seq OWNED BY public.ferias.id_feria;


--
-- Name: gastronomia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gastronomia (
    id_gastronomia integer NOT NULL,
    id_destino integer NOT NULL,
    descripcion text NOT NULL,
    contacto character varying(30),
    foto_referencia character varying(255)
);


--
-- Name: gastronomia_id_gastronomia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gastronomia_id_gastronomia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gastronomia_id_gastronomia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gastronomia_id_gastronomia_seq OWNED BY public.gastronomia.id_gastronomia;


--
-- Name: habitacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.habitacion (
    id_habitacion integer NOT NULL,
    id_hotel integer NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    tipo_cama character varying(60),
    capacidad integer DEFAULT 2 NOT NULL,
    precio numeric(12,2) NOT NULL,
    foto_referencia character varying(255),
    activa boolean DEFAULT true NOT NULL,
    CONSTRAINT habitacion_capacidad_check CHECK (((capacidad >= 1) AND (capacidad <= 10))),
    CONSTRAINT habitacion_precio_check CHECK ((precio > (0)::numeric))
);


--
-- Name: habitacion_id_habitacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.habitacion_id_habitacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: habitacion_id_habitacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.habitacion_id_habitacion_seq OWNED BY public.habitacion.id_habitacion;


--
-- Name: hotel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hotel (
    id_hotel integer NOT NULL,
    id_destino integer NOT NULL,
    id_propietario integer,
    nombre character varying(150) NOT NULL,
    foto_referencia character varying(255),
    direccion character varying(200),
    descripcion text,
    contacto character varying(50),
    categoria character varying(50),
    politicas text,
    activo boolean DEFAULT true NOT NULL,
    fecha_registro timestamp without time zone DEFAULT now() NOT NULL,
    id_solicitud integer
);


--
-- Name: hotel_id_hotel_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hotel_id_hotel_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hotel_id_hotel_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hotel_id_hotel_seq OWNED BY public.hotel.id_hotel;


--
-- Name: solicitud_admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solicitud_admin (
    id_solicitud integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellidos character varying(100),
    documento character varying(30) NOT NULL,
    cargo character varying(60) NOT NULL,
    correo character varying(150) NOT NULL,
    telefono character varying(30),
    password_hash character varying(255) NOT NULL,
    nombre_hotel character varying(150) NOT NULL,
    direccion_hotel character varying(200) NOT NULL,
    contacto_hotel character varying(50) NOT NULL,
    categoria character varying(50) NOT NULL,
    descripcion text NOT NULL,
    politicas text NOT NULL,
    id_destino integer,
    estado public.estado_solicitud DEFAULT 'pendiente'::public.estado_solicitud NOT NULL,
    fecha_registro timestamp without time zone DEFAULT now() NOT NULL,
    fecha_resolucion timestamp without time zone,
    resuelta_por integer,
    motivo_rechazo text
);


--
-- Name: solicitud_admin_id_solicitud_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solicitud_admin_id_solicitud_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solicitud_admin_id_solicitud_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solicitud_admin_id_solicitud_seq OWNED BY public.solicitud_admin.id_solicitud;


--
-- Name: transporte; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transporte (
    id_transporte integer NOT NULL,
    id_destino integer NOT NULL,
    descripcion text NOT NULL,
    contacto character varying(30),
    foto_referencia character varying(255)
);


--
-- Name: transporte_id_transporte_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transporte_id_transporte_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transporte_id_transporte_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transporte_id_transporte_seq OWNED BY public.transporte.id_transporte;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellidos character varying(100),
    ciudad character varying(100),
    direccion character varying(200),
    correo character varying(150) NOT NULL,
    telefono character varying(30),
    documento character varying(30),
    rol public.rol_usuario DEFAULT 'usuario'::public.rol_usuario NOT NULL,
    password_hash character varying(255) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    fecha_registro timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- Name: viaje_habitacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.viaje_habitacion (
    id_vh integer NOT NULL,
    id_vp integer NOT NULL,
    id_habitacion integer NOT NULL,
    personas_asignadas integer NOT NULL,
    precio_noche numeric(12,2) NOT NULL,
    fechas daterange NOT NULL,
    activa boolean DEFAULT true NOT NULL,
    CONSTRAINT viaje_habitacion_personas_asignadas_check CHECK ((personas_asignadas >= 1))
);


--
-- Name: v_habitacion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_habitacion AS
 SELECT id_habitacion,
    id_hotel,
    nombre,
    descripcion,
    tipo_cama,
    capacidad,
    precio,
    foto_referencia,
    activa,
    (EXISTS ( SELECT 1
           FROM public.viaje_habitacion vh
          WHERE ((vh.id_habitacion = hab.id_habitacion) AND vh.activa AND (upper(vh.fechas) > CURRENT_DATE)))) AS ocupada
   FROM public.habitacion hab
  WHERE activa;


--
-- Name: v_hotel; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_hotel AS
SELECT
    NULL::integer AS id_hotel,
    NULL::integer AS id_destino,
    NULL::integer AS id_propietario,
    NULL::character varying(150) AS nombre,
    NULL::character varying(255) AS foto_referencia,
    NULL::character varying(200) AS direccion,
    NULL::text AS descripcion,
    NULL::character varying(50) AS contacto,
    NULL::character varying(50) AS categoria,
    NULL::text AS politicas,
    NULL::boolean AS activo,
    NULL::timestamp without time zone AS fecha_registro,
    NULL::bigint AS total_habitaciones,
    NULL::numeric AS precio_promedio,
    NULL::bigint AS habitaciones_ocupadas,
    NULL::numeric AS porcentaje_ocupacion;


--
-- Name: viaje_habitacion_id_vh_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.viaje_habitacion_id_vh_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: viaje_habitacion_id_vh_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.viaje_habitacion_id_vh_seq OWNED BY public.viaje_habitacion.id_vh;


--
-- Name: viaje_personalizado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.viaje_personalizado (
    id_vp integer NOT NULL,
    id_usuario integer NOT NULL,
    id_destino integer NOT NULL,
    id_hotel integer NOT NULL,
    fecha_inicial date NOT NULL,
    fecha_final date NOT NULL,
    num_personas integer NOT NULL,
    precio numeric(14,2) DEFAULT 0 NOT NULL,
    estado public.estado_viaje DEFAULT 'reservado'::public.estado_viaje NOT NULL,
    fecha_registro timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT viaje_personalizado_check CHECK ((fecha_final > fecha_inicial)),
    CONSTRAINT viaje_personalizado_num_personas_check CHECK ((num_personas >= 1))
);


--
-- Name: viaje_personalizado_id_vp_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.viaje_personalizado_id_vp_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: viaje_personalizado_id_vp_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.viaje_personalizado_id_vp_seq OWNED BY public.viaje_personalizado.id_vp;


--
-- Name: actividades id_actividades; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividades ALTER COLUMN id_actividades SET DEFAULT nextval('public.actividades_id_actividades_seq'::regclass);


--
-- Name: deptos id_depto; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deptos ALTER COLUMN id_depto SET DEFAULT nextval('public.deptos_id_depto_seq'::regclass);


--
-- Name: destinos id_destino; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinos ALTER COLUMN id_destino SET DEFAULT nextval('public.destinos_id_destino_seq'::regclass);


--
-- Name: ferias id_feria; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ferias ALTER COLUMN id_feria SET DEFAULT nextval('public.ferias_id_feria_seq'::regclass);


--
-- Name: gastronomia id_gastronomia; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gastronomia ALTER COLUMN id_gastronomia SET DEFAULT nextval('public.gastronomia_id_gastronomia_seq'::regclass);


--
-- Name: habitacion id_habitacion; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.habitacion ALTER COLUMN id_habitacion SET DEFAULT nextval('public.habitacion_id_habitacion_seq'::regclass);


--
-- Name: hotel id_hotel; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel ALTER COLUMN id_hotel SET DEFAULT nextval('public.hotel_id_hotel_seq'::regclass);


--
-- Name: solicitud_admin id_solicitud; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitud_admin ALTER COLUMN id_solicitud SET DEFAULT nextval('public.solicitud_admin_id_solicitud_seq'::regclass);


--
-- Name: transporte id_transporte; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transporte ALTER COLUMN id_transporte SET DEFAULT nextval('public.transporte_id_transporte_seq'::regclass);


--
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- Name: viaje_habitacion id_vh; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_habitacion ALTER COLUMN id_vh SET DEFAULT nextval('public.viaje_habitacion_id_vh_seq'::regclass);


--
-- Name: viaje_personalizado id_vp; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_personalizado ALTER COLUMN id_vp SET DEFAULT nextval('public.viaje_personalizado_id_vp_seq'::regclass);


--
-- Data for Name: actividades; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.actividades (id_actividades, id_destino, descripcion, contacto, foto_referencia) FROM stdin;
3	2	Vive la magia del cafÃ© desde su origen con un recorrido guiado entre cafetales y aromas tradicionales.	3009090909	/actividades/CAMINAR_JARDIN.png
6	3	Siente la libertad recorriendo los caminos veredales a caballo con vistas espectaculares de la cordillera.	3010101010	/actividades/CABALLOS_SALENTO.png
8	4	Captura la luz dorada desde miradores estratÃ©gicos mientras el sol se oculta sobre las montaÃ±as cafeteras.	3011111111	/actividades/ATARDECER_FILANDIA.png
9	5	Viaja en el tiempo caminando por el empedrado ancestral del Camino Real que conecta Barichara con Guane.	3012121212	/actividades/CAMINO_REAL_BARICHARA.png
10	5	Descubre los secretos de la arquitectura colonial en tapia pisada recorriendo las calles mÃ¡s bellas de Colombia.	3012121212	/actividades/CASAS_BARICHARA.png
12	6	Explora el paisaje desÃ©rtico de La Candelaria y descubre monasterios antiguos llenos de paz y misticismo.	3013131313	/actividades/CANDELARIA_VILLALEYVA.png
14	7	Navega pacÃ­ficamente por las aguas del rÃ­o Magdalena a bordo de un tradicional champÃ¡n al atardecer.	3014141414	/actividades/CHAMPAN_MOMPOX.png
18	17	MaravÃ­llate con el imponente Arco del Morro, una formaciÃ³n rocosa natural labrada por el OcÃ©ano PacÃ­fico.	3015151515	/actividades/ARCO_TUMACO.png
19	17	EmbÃ¡rcate en un fascinante avistamiento de ballenas jorobadas mientras surcan las aguas cÃ¡lidas del PacÃ­fico.	3015151515	/actividades/BALLENASJO_TUMACO.png
21	9	Recorre las encantadoras calles coloniales de Buga y descubre el patrimonio histÃ³rico de su centro urbano.	3016161616	/actividades/CENTRO_HISTORICO_BUGA.png
22	9	Visita la emblemÃ¡tica BasÃ­lica del SeÃ±or de los Milagros y vive una experiencia cultural y espiritual Ãºnica.	3016161616	/actividades/MILAGROS_BUGA.png
23	16	Contempla la impresionante arquitectura gÃ³tica del Santuario de Las Lajas incrustado en el caÃ±Ã³n del rÃ­o GuÃ¡itara.	3018181818	/actividades/IGLESIA_SANTUARIO.png
24	16	Cruza el puente del Santuario de Las Lajas y disfruta de las vistas panorÃ¡micas mÃ¡s deslumbrantes de la frontera.	3018181818	/actividades/PUENTE_SANTUARIO.png
25	10	Navega por las serenas aguas del Lago Calima en un relajante paseo en lancha rodeado de paisajes verdes.	3019191919	/actividades/LANCHA_LAGOCALIMA.png
26	10	Aprovecha los potentes vientos del Lago Calima para vivir la adrenalina del windsurf y deportes acuÃ¡ticos.	3019191919	/actividades/WINDSURF_LAGOCALIMA.png
27	15	Recorre los senderos ecolÃ³gicos rodeados de frailejones y naturaleza mÃ­stica alrededor de la Laguna La Cocha.	3018181818	/actividades/SENDERISMO_LAGUNACOCHA.png
28	15	Navega en lancha por las frÃ­as y pacÃ­ficas aguas de la Laguna La Cocha hasta la isla de La Corota.	3018181818	/actividades/LANCHAS_LAGUNACOCHA.png
29	11	AdÃ©ntrate en la selva tropical de San Cipriano a bordo de las tradicionales brujitas y nada en sus rÃ­os cristalinos.	3017171717	/actividades/SANCIPRIANO_BUENAVENTURA.png
30	1	Sube los escalones de la imponente Piedra del PeÃ±ol para disfrutar de una vista panorÃ¡mica de 360 grados sobre el embalse.	3001010101	/actividades/PIEDRA_GUATAPE.avif
31	1	DiviÃ©rtete en las atracciones acuÃ¡ticas e inflables en las aguas cristalinas del embalse de GuatapÃ©.	3001010101	/actividades/INFLA_GUATAPE.jpg
32	2	Admira la impresionante arquitectura neogÃ³tica de la BasÃ­lica Menor de la Inmaculada ConcepciÃ³n en la plaza principal.	3009090909	/actividades/BASILICA_JARDIN.jpg
33	28	Disfruta de parques acuÃ¡ticos y piscinas para refrescarte bajo el cÃ¡lido clima colonial.	3015151515	/actividades/ACUATICA_SANTAFE.jpg
34	28	Recorre sus histÃ³ricas calles empedradas, fuentes coloniales y la hermosa arquitectura de sus iglesias.	3015151515	/actividades/CENTRO_HISTORICO_SANTAFE.jpg
35	7	Vive la vibrante cultura, mÃºsica y expresiones artÃ­sticas durante los festivales tradicionales a orillas del rÃ­o.	3014141414	/actividades/FESTIVAL_MOMPOX.webp
36	29	Explora las paradisÃ­acas aguas turquesas e islas de arena blanca del ArchipiÃ©lago del Rosario.	3016161616	/actividades/ARCHIPIELAGO_CARTAGENA.avif
37	29	Descubre el encanto colonial, plazas centenarias y la majestuosidad del centro histÃ³rico amurallado.	3016161616	/actividades/PARQUE_CARTAGENA.jpeg
38	30	Conecta con las raÃ­ces africanas, la mÃºsica tradicional del tambor y la gastronomÃ­a ancestral del primer pueblo libre de AmÃ©rica.	3017171717	/actividades/RAICES_SANBASILIO.jpg
39	30	Visita la plaza principal y el monumento a Benkos BiohÃ³ para aprender sobre la historia de libertad y resistencia.	3017171717	/actividades/MONUMENTO_SANBASILIO.jpg
41	6	DÃ©jate envolver por la magia de las plazas monumentales y el ambiente colonial Ãºnico de Villa de Leyva.	3013131313	/actividades/MAGICA_VILLALEYVA.avif
42	31	Visita el imponente monumento a los Lanceros en el Pantano de Vargas, lugar histÃ³rico de la independencia.	3019191919	/actividades/PANTANO_PAIPA.jpg
43	31	RelÃ¡jate y renueva tus energÃ­as en las famosas piscinas de aguas termales con propiedades medicinales.	3019191919	/actividades/PIS_PAIPA.jpg
44	32	Realiza desafiantes caminatas y escalada en las imponentes cumbres nevadas del Parque Nacional Natural.	3020202020	/actividades/ESCALADA_COCUY.jpg
45	32	Camina hasta la majestuosa formaciÃ³n rocosa del PÃºlpito del Diablo rodeada de glaciares espectaculares.	3020202020	/actividades/PULPITO_COCUY.jpg
46	8	Vive la emociÃ³n del rafting descendiendo por los apasionantes rÃ¡pidos del rÃ­o Magdalena.	3021212121	/actividades/RAFTING_SANAGUSTIN.jpg
47	8	MaravÃ­llate con las imponentes caÃ­das de agua y la naturaleza exuberante que rodea la regiÃ³n.	3021212121	/actividades/CASCADA_SANAGUSTIN.jpg
48	33	Aprende sobre las tradiciones y la vida local de las comunidades que habitan el ecosistema Ã¡rido.	3022222222	/actividades/COMUNIDAD_DESIERTOTATACOA.avif
49	33	Recorre los fascinantes laberintos rojizos y grises del desierto en un paseo a caballo.	3022222222	/actividades/CABALLO_DESIERTOTATACOA.avif
50	3	Camina entre las majestuosas Palmas de Cera, los Ã¡rboles nacionales de Colombia, en el emblemÃ¡tico Valle del Cocora.	3002020202	/actividades/PALMAS_SALENTO.jpg
60	36	Disfruta de la naturaleza y recorre los hermosos senderos del parque natural en la capital del turismo de aventura.	3012121212	/actividades/PARQUENATURAL_SANGIL.jpg
62	34	RelÃ¡jate y descansa en las deliciosas aguas termales naturales en un entorno tranquilo y verde.	3008080808	/actividades/TERMAL_RIVERA.avif
63	34	Explora los senderos ecoturÃ­sticos y admira la fauna local observando los guÃ¡charos en la regiÃ³n.	3008080808	/actividades/GUACHARO_RIVERA.jpg
64	36	Siente la adrenalina volando sobre el majestuoso caÃ±Ã³n en una experiencia inolvidable de tirolesa.	3012121212	/actividades/TIROLESA_SANGIL.jpg
65	36	Disfruta de la naturaleza y recorre los hermosos senderos del parque natural en la capital del turismo de aventura.	3012121212	/actividades/PARQUENATURAL_SANGIL.jpg
67	35	Siente la adrenalina pura en la icÃ³nica montaÃ±a rusa rodeada de exuberante vegetaciÃ³n cafetera.	3002020202	/actividades/MONTAÃ‘ARUSA_PARQUECAFE.png
68	35	Disfruta de las muestras culturales y artÃ­sticas tradicionales de la regiÃ³n cafetera.	3002020202	/actividades/SHOW_PARQUECAFE.jpg
69	4	Visita la majestuosa iglesia central y admira la arquitectura colonial del municipio.	3003030303	/actividades/IGLESIA_FILANDIA.jpg
70	37	DiviÃ©rtete en las emocionantes atracciones extremas con vista al majestuoso caÃ±Ã³n.	3012121212	/actividades/ATRACCIÃ“N_CHICAMOCHA.jpg
71	37	RelÃ¡jate y disfruta de un refrescante baÃ±o en el parque acuÃ¡tico rodeado de montaÃ±as.	3012121212	/actividades/PISCINA_CHICAMOCHA.webp
72	11	Avista a las impresionantes ballenas jorobadas en sus aguas pacÃ­ficas.	3007070707	/actividades/BALLENAS_BUENAVENTURA.png
\.


--
-- Data for Name: deptos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deptos (id_depto, nombre, foto_referencia, descripcion) FROM stdin;
1	Antioquia	/deptos/ANTIOQUIA.jpg	Tierra de montaÃ±as, pueblos coloridos y la vibrante MedellÃ­n. Ideal para turismo cultural y de aventura.
5	BolÃ­var	/deptos/BOLIVAR.png	Hogar de Cartagena, con playas caribeÃ±as, historia colonial y arquitectura amurallada.
4	BoyacÃ¡	/deptos/BOYACA.jpg	Pueblos patrimonio, paisajes andinos y la histÃ³rica Villa de Leyva. Perfecto para turismo histÃ³rico y rural.
6	Huila	/deptos/HUILA.jpg	Cuna del Desierto de la Tatacoa y el Parque ArqueolÃ³gico de San AgustÃ­n. Naturaleza y misterio ancestral.
2	QuindÃ­o	/deptos/QUINDIO.jpg	CorazÃ³n del Eje Cafetero, con el Valle de Cocora, fincas cafeteras y pueblos como Salento y Filandia.
3	Santander	/deptos/SANTANDER.webp	Destino de deportes extremos, caÃ±ones impresionantes y el pueblo colonial de Barichara.
8	NariÃ±o	/deptos/NARIÃ‘O.webp	Tierra de cultura, el majestuoso Santuario de Las Lajas, la Laguna de la Cocha y paisajes andinos Ãºnicos.
7	Valle del Cauca	/deptos/VALLE_DEL_CAUCA.jpg	RegiÃ³n del PacÃ­fico con diversidad cultural, paisajes de montaÃ±a y mar, Lago Calima y la BasÃ­lica de Buga.
\.


--
-- Data for Name: destinos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.destinos (id_destino, id_depto, nombre, foto_referencia, clima, generalidades, fecha_registro) FROM stdin;
9	7	Buga	/destinos/BUGA.png	CÃ¡lido y agradable	Es un destino conocido principalmente por la BasÃ­lica del SeÃ±or de los Milagros. Los turistas pueden conocer su patrimonio religioso, recorrer sus calles y disfrutar de la gastronomÃ­a local.	2026-09-02 10:09:17.319101
10	7	Lago Calima	/destinos/LAGO_CALIMA.png	Templado y fresco	Es un destino rodeado de naturaleza y paisajes atractivos. Es conocido por sus actividades acuÃ¡ticas, paseos, deportes y espacios ideales para disfrutar de un dÃ­a al aire libre.	2026-09-02 10:09:17.319101
11	7	Buenaventura	/destinos/BUENAVENTURA.png	CÃ¡lido y hÃºmedo	Es uno de los principales destinos del PacÃ­fico colombiano, reconocido por sus playas, biodiversidad y cultura. Los turistas pueden disfrutar de la naturaleza, la gastronomÃ­a y conocer diferentes lugares de la regiÃ³n.	2026-09-02 10:09:17.319101
6	4	Villa de Leyva	/destinos/VILLA_DE_LEYVA.jpg	Templado y seco	Pueblo colonial con la plaza empedrada mÃ¡s grande de Colombia, rodeado de desierto y fÃ³siles.	2026-08-20 21:21:04.432456
1	1	GuatapÃ©	/destinos/GUATAPE.avif	Templado y moderado	Pueblo de casas coloridas y zÃ³calos junto al embalse, uno de los mÃ¡s visitados de Antioquia.	2026-08-20 21:21:04.432456
2	1	JardÃ­n	/destinos/JARDIN.png	Templado y fresco	Pueblo cafetero de fachadas de colores vivos, rodeado de montaÃ±as y fincas cafeteras.	2026-08-20 21:21:04.432456
3	2	Salento	/destinos/SALENTO.jpg	Templado y fresco	Pueblo quindiano famoso por el Valle de Cocora y las palmas de cera mÃ¡s altas del mundo.	2026-08-20 21:21:04.432456
4	2	Filandia	/destinos/FILANDIA.webp	Templado y fresco	Pueblo cafetero tranquilo con arquitectura tradicional y miradores sobre el QuindÃ­o.	2026-08-20 21:21:04.432456
5	3	Barichara	/destinos/BARICHARA.webp	Templado y seco	Considerado uno de los pueblos mÃ¡s bonitos de Colombia, calles empedradas y casas de tapia pisada.	2026-08-20 21:21:04.432456
7	5	Mompox	/destinos/MOMPOX.jpg	CÃ¡lido y hÃºmedo	Pueblo colonial a orillas del rÃ­o Magdalena, patrimonio de la humanidad, tradiciÃ³n orfebre.	2026-08-20 21:21:04.432456
8	6	San AgustÃ­n	/destinos/SAN_AGUSTIN.webp	Templado	Pueblo huilense famoso por sus estatuas precolombinas y paisajes de montaÃ±a.	2026-08-20 21:21:04.432456
15	8	Laguna La Cocha	/destinos/LAGUNA_LA_COCHA.png	FrÃ­o y hÃºmedo	Es un hermoso destino natural rodeado de montaÃ±as y vegetaciÃ³n exuberante. Los turistas pueden disfrutar de paseos en barco, observar la naturaleza y visitar la isla de La Corota.	2026-09-02 16:48:24.452037
16	8	Santuario de Las Lajas	/destinos/SANTUARIO.png	Templado y fresco	Es uno de los lugares mÃ¡s emblemÃ¡ticos de NariÃ±o, famoso por su impresionante arquitectura construida en un caÃ±Ã³n. Es ideal para conocer su historia, disfrutar del paisaje y experimentar el turismo religioso.	2026-09-02 16:48:24.452037
17	8	Tumaco	/destinos/TUMACO.png	CÃ¡lido y hÃºmedo	Un destino situado en la costa pacÃ­fica de Colombia, famoso por sus playas, cultura y gastronomÃ­a. Los visitantes pueden disfrutar del mar, probar platos locales y aprender sobre las tradiciones de la regiÃ³n.	2026-09-02 16:48:24.452037
28	1	Santa Fe de Antioquia	/destinos/SANTA_FE.png	CÃ¡lido seco, temperatura promedio entre 27Â°C y 30Â°C durante todo el aÃ±o.	Es una ciudad histÃ³rica reconocida por su arquitectura colonial, calles adoquinadas y clima cÃ¡lido. Los turistas pueden explorar el centro histÃ³rico, visitar el Western Bridge y disfrutar de su gastronomÃ­a y paisajes.	2026-09-02 19:31:13.574121
29	5	Cartagena de Indias	/destinos/CARTAGENA_DE_INDIAS.png	CÃ¡lido tropical costero, temperatura promedio entre 28Â°C y 32Â°C, con alta humedad.	Es uno de los destinos turÃ­sticos mÃ¡s reconocidos de Colombia, famoso por su centro histÃ³rico, sus murallas y sus playas. Los visitantes pueden explorar la Ciudad Amurallada, saborear la gastronomÃ­a local y descubrir lugares histÃ³ricos.	2026-09-02 19:31:13.574121
30	5	San Basilio de Palenque	/destinos/SAN_BASILIO.png	CÃ¡lido tropical, temperatura promedio alrededor de 28Â°C, similar al clima de Cartagena.	Es un destino reconocido por su historia, cultura y tradiciones afrocolombianas. Los visitantes pueden experimentar sus expresiones musicales, gastronomÃ­a, artesanÃ­a y aprender sobre las tradiciones de su comunidad.	2026-09-02 19:31:13.574121
31	4	Paipa	/destinos/PAIPA.png	FrÃ­o de altiplano, temperatura promedio entre 12Â°C y 18Â°C.	Es un destino conocido por sus aguas termales, paisajes y actividades relajantes. Los visitantes pueden disfrutar de las aguas termales, participar en deportes acuÃ¡ticos y explorar el lago Sochagota.	2026-09-02 19:31:13.574121
32	4	El Cocuy	/destinos/EL_COCUY.png	FrÃ­o de pÃ¡ramo, con temperaturas bajo cero en los picos nevados y cerca de 12Â°C-14Â°C en el pueblo.	Es un destino ideal para los amantes de la naturaleza y de la montaÃ±a. Destaca por sus paisajes, picos nevados y senderos, donde los turistas pueden hacer senderismo y disfrutar de la biodiversidad.	2026-09-02 19:31:13.574121
33	6	Desierto de Tatacoa	/destinos/DESIERTO_TATACOA.png	CÃ¡lido y muy seco, temperaturas diurnas que superan los 35Â°C y noches frescas.	Es uno de los lugares naturales mÃ¡s emblemÃ¡ticos de Huila, conocido por sus paisajes de color gris rojizo. Los turistas pueden hacer senderismo, explorar sus formaciones naturales y disfrutar de la observaciÃ³n de las estrellas.	2026-09-02 19:31:13.574121
34	6	Rivera	/destinos/RIVERA.png	CÃ¡lido, temperatura promedio alrededor de 28Â°C.	Es un municipio conocido por sus aguas termales y paisajes naturales. Los turistas pueden disfrutar de los balnearios, relajarse en las aguas termales y explorar los alrededores.	2026-09-02 19:31:13.574121
35	2	Parque de CafÃ©	/destinos/PARQUE_CAFE.png	Templado de zona cafetera, temperatura promedio entre 18Â°C y 22Â°C.	Es una de las principales atracciones turÃ­sticas de QuindÃ­o, donde los visitantes pueden aprender mÃ¡s sobre la cultura cafetera y disfrutar de diversas atracciones. Es ideal para pasar el dÃ­a en familia y disfrutar de actividades recreativas.	2026-09-02 19:31:13.574121
36	3	San Gil	/destinos/SAN_GIL.png	Templado, temperatura promedio entre 22Â°C y 25Â°C.	Es uno de los destinos de aventura mÃ¡s populares de Santander. Los turistas pueden disfrutar de actividades como rafting, senderismo y explorar los paisajes naturales de la regiÃ³n.	2026-09-02 19:31:13.574121
37	3	Chicamocha	/destinos/CHICAMOCHA.png	CÃ¡lido y seco en el fondo del caÃ±Ã³n, temperatura promedio entre 26Â°C y 30Â°C.	El CaÃ±Ã³n Chicamocha es uno de los paisajes naturales mÃ¡s impresionantes de Santander. Los turistas pueden visitar el Parque Nacional de Chicamocha, disfrutar del telefÃ©rico y admirar las montaÃ±as y el caÃ±Ã³n.	2026-09-02 19:31:13.574121
\.


--
-- Data for Name: ferias; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ferias (id_feria, id_depto, id_destino, nombre, tipo, descripcion, foto_referencia, fecha_inicio, fecha_fin, descuento_porcentaje, activo) FROM stdin;
1	4	\N	Festival del Torbellino	feria	CelebraciÃ³n tradicional con mÃºsica, danza y gastronomÃ­a tÃ­pica boyacense.	\N	2026-10-01	2026-10-05	\N	t
2	4	32	Festival de la Nieve	feria	CelebraciÃ³n tradicional en el pÃ¡ramo, con caminatas guiadas y gastronomÃ­a tÃ­pica.	\N	2026-10-05	2026-10-08	\N	t
3	1	1	Feria de Octubre	feria	Feria cultural y gastronÃ³mica.	\N	2026-10-10	2026-10-12	\N	t
4	4	32	Escapada de montaÃ±a a El Cocuy	oferta	Hospedaje 2 noches con descuento especial de temporada.	\N	2026-09-20	2026-10-10	18.00	t
\.


--
-- Data for Name: gastronomia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.gastronomia (id_gastronomia, id_destino, descripcion, contacto, foto_referencia) FROM stdin;
8	8	Asado huilense tradicional, plato tÃ­pico de San AgustÃ­n.	3007070707	/gastronomia/ASADO_SANAGUSTIN.png
6	6	Longaniza artesanal boyacense, servida tradicionalmente en la plaza principal.	3005050505	/gastronomia/LONGANIZA_BOYACA.png
4	4	CafÃ© filandiano en tostadoras locales.	3003030303	/gastronomia/CAFE_FILANDIANO_FILANDIA.png
9	2	Arepas de mote rellenas, especialidad de las fondas de JardÃ­n.	3001010101	/gastronomia/AREPAS_JARDIN.webp
10	2	Picada paisa para compartir, con chicharrÃ³n, chorizo y arepa.	3001010101	/gastronomia/PICADA_JARDIN.webp
11	3	PatacÃ³n con hogao y queso, acompaÃ±ante infaltable en Salento.	3002020202	/gastronomia/PATACON_SALENTO.png
12	3	Trucha fresca servida con vista al Valle de Cocora.	3002020202	/gastronomia/TRUCHA_COCORA_GUATAPE.jpg
5	5	Cabrito guisado tradicional, delicia santandereana.	3004040404	/gastronomia/CABRITO_GUISADO_BARICHARA.png
7	7	Pescado de rÃ­o, arroz de frÃ­jol y dulces de Mompox.	3006060606	/gastronomia/PESCADO_RIO_MOMPOX.png
2	2	CafÃ© de origen local, cultivado en las fincas tradicionales de JardÃ­n.	3001010101	/gastronomia/CAFE_JARDIN.jpg
15	5	Variedad de delicias santandereanas para compartir.	3004040404	/gastronomia/DELICIAS_SANTANDEREANAS_BARICHARA.png
16	5	Hormiga culona tostada, manjar tradicional santandereano.	3004040404	/gastronomia/HORMIGA_CULONA_BARICHARA.png
17	6	Mazorca asada boyacense, infaltable en las plazas de pueblo.	3005050505	/gastronomia/MAZORCA_BOYACA.png
18	6	Chicha de maÃ­z, bebida tradicional boyacense.	3005050505	/gastronomia/CHICHA_BOYACA.png
19	7	Arroz con frÃ­jol, plato tÃ­pico de Mompox.	3006060606	/gastronomia/ARROZ_FRIJOL_MOMPOX.png
20	7	Dulces artesanales de Mompox, herencia de la DepresiÃ³n Momposina.	3006060606	/gastronomia/DULCES_MOMPOX.png
21	8	Bizcocho de achira reciÃ©n horneado, tÃ­pico de San AgustÃ­n.	3007070707	/gastronomia/ACHIRA_SANAGUSTIN.png
22	28	Bandeja paisa tradicional con frijoles, chicharrÃ³n, carne molida, chorizo, huevo frito, tajada de plÃ¡tano, aguacate y arepa.	\N	/gastronomia/BANDEJA_PAISA_SANTAFE.png
23	28	Tamal antioqueÃ±o envuelto en hoja de plÃ¡tano, servido caliente con arepa de maÃ­z.	\N	/gastronomia/TAMAL_SANTAFE.png
24	28	Sopa de mondongo tradicional acompaÃ±ada de mazorca, arroz y aguacate.	\N	/gastronomia/MONDONGO_SANTAFE.png
25	28	Arepa antioqueÃ±a de maÃ­z blanco, dorada al carbÃ³n, ideal para acompaÃ±ar con mantequilla y queso.	\N	/gastronomia/AREPA_ANTIOQUEÃ‘A_SANTAFE.png
26	29	Arroz con coco tradicional cartagenero, de sabor dulce y dorado, elaborado con leche de coco y titotÃ©.	\N	/gastronomia/ARROZ_COCO_CARTAGENA.png
27	29	Pescado frito crujiente acompaÃ±ado de patacones de plÃ¡tano verde y ensalada fresca.	\N	/gastronomia/PESCADO_PATACONES_CARTAGENA.png
28	29	Cazuela de mariscos cremosa preparada con leche de coco, camarones, calamares y especias caribeÃ±as.	\N	/gastronomia/CAZUELA_CARTAGENA.png
29	30	Arroz con coco artesanal de Palenque, preparado con tÃ©cnica tradicional de titotÃ© y leche de coco fresca.	\N	/gastronomia/ARROZ_COCO_BASILIO.png
30	30	CarimaÃ±olas crujientes de yuca rellenas de carne molida frita, plato tÃ­pico de la herencia afrocolombiana.	\N	/gastronomia/CARIMAÃ‘OLAS_BASILIO.png
31	30	Pescado guisado en zumo de coco y hortalizas, una receta ancestral llena de sabor caribeÃ±o.	\N	/gastronomia/PECADO_GUISADO_BASILIO.png
32	31	Arepa boyacense tradicional de maÃ­z amarillo rellena de queso Paipa y horneada al carbÃ³n.	\N	/gastronomia/AREPA_BOYA_PAIPA.png
33	31	Cocido boyacense preparado con tubÃ©rculos andinos como ibias, cubios, chuguas y carnes variadas.	\N	/gastronomia/COCIDO_PAIPA.png
34	31	Cuchuco de trigo con espinazo de cerdo, sopa espesa tradicional de los campos boyacenses.	\N	/gastronomia/CUCHUCO_PAIPA.png
35	31	Mazamorra chiquita boyacense, sopa tradicional a base de maÃ­z, menudencias, carne y verduras.	\N	/gastronomia/MAZAMORRA_CHIQUI_PAIPA.png
36	31	Changua boyacense preparada con leche, huevo calfado, cilantro fresco y calado.	\N	/gastronomia/CHANGUA_PAIPA.png
37	32	Mute boyacense reconfortante, preparado con maÃ­z pelado, carne de res, cerdo y verduras de la sierra.	\N	/gastronomia/MUTE_COCUY.png
38	32	Cocido tÃ­pico de la sierra con tubÃ©rculos andinos, longaniza, carne de cerdo y mazorca.	\N	/gastronomia/COCIDO_COCUY.png
39	32	Cuchuco tradicional servido bien caliente, ideal para el clima de alta montaÃ±a en El Cocuy.	\N	/gastronomia/CUCHUCO_COCUY.png
40	9	Sancocho de gallina tradicional cocinado a la leÃ±a, acompaÃ±ado de platano, yuca y mazorca.	\N	/gastronomia/SANCOCHO_BUGA.png
41	9	Chuleta valluna apanada, crujiente por fuera y jugosa por dentro, emblema del Valle del Cauca.	\N	/gastronomia/CHULETA_BUGA.png
42	9	Arroz atollado espeso y sazonado, preparado con diferentes carnes, verduras y guiso criollo.	\N	/gastronomia/ATOLLADO_BUGA.png
43	9	Manjar blanco valluno, postre artesanal a base de leche y azÃºcar servido en mate tradicional.	\N	/gastronomia/MANJAR_BLANCO_BUGA.png
44	17	Encocado tradicional tumaqueÃ±o preparado con leche de coco fresca, refrito pacÃ­fico y hierbas azoteas.	\N	/gastronomia/ENCOCADO_TUMACO.png
45	17	Cebiche o salteado de camarÃ³n y piangua extraÃ­da de los manglares, sazonado con limÃ³n y cilantro de monte.	\N	/gastronomia/CAMARON_PIANGUA_TUMACO.png
46	17	Arroz marinero estilo Tumaco, sazonado con achiote, frutos del mar y coco.	\N	/gastronomia/ARROZ_MARINERO.png
47	16	Cuy asado a las brasas, plato insignia nariÃ±ense servido con papas al vapor y ajÃ­ de manÃ­.	\N	/gastronomia/CUY_SANTUARIO.png
48	16	Hornado pastuso, jugosa carne de cerdo asada en horno de leÃ±a acompaÃ±ada de mote y agrio.	\N	/gastronomia/HORNADO_SANTUARIO.png
49	16	Empanadas de aÃ±ejo crujientes preparadas con masa de maÃ­z fermentado y guiso tradicional.	\N	/gastronomia/EMPANADAS_AÃ‘EJO_SANTUARIO.png
50	15	Trucha arcoÃ­ris frita o a la plancha, plato insignia cultivado en las frÃ­as aguas de La Cocha.	\N	/gastronomia/TRUCHA_LAGUNA_COCHA.png
51	15	Plato tÃ­pico nariÃ±ense acompaÃ±ado de trucha frita, papas al vapor, ensalada fresca y patacÃ³n.	\N	/gastronomia/PLATO_TIPICO_LAGUNA_COCHA.png
52	15	AcompaÃ±amientos tradicionales regionales como arepas de choclo, queso campesino y hervidos calientes.	\N	/gastronomia/ACOMPAÃ‘AMIENTOS_LAGUNA_COCHA.png
53	11	Pescado fresco baÃ±ado en suculenta salsa de coco, refrito del PacÃ­fico y finas hierbas azoteas.	\N	/gastronomia/ENCOCADO_PESCADO_BUENAVENTURA.png
54	11	Arroz autÃ³ctono sazonado con variedad de mariscos del PacÃ­fico, piangua, camarones y achiote.	\N	/gastronomia/ARROZ_MARISCOS_BUENAVENTURA.png
55	11	Cazuela cremosa de mariscos frescos cocinada en leche de coco, servida en cazuela de barro caliente.	\N	/gastronomia/CAZUELA_MARISCOS_BUENAVENTURA.png
56	1	Trucha frita tradicional servida fresca en los restaurantes junto al embalse de GuatapÃ©.	3009990011	/gastronomia/TRUCHA_GUATAPE.jpg
57	1	Bandeja paisa tÃ­pica con frijoles, chicharrÃ³n, carne molida, huevo, tajada y arepa.	3009990011	/gastronomia/BANDEJA_GUATAPE.jpg
1	1	Mazamorra antioqueÃ±a tradicional acompaÃ±ada con bocadillo y leche.	3009990011	/gastronomia/MAZAMORRA_GUATAPE.jpg
58	8	Torteaditos tradicionales, plato tÃ­pico de San AgustÃ­n.	3007070707	/gastronomia/TORTEADITOS_SANAGUSTIN.jpg
59	4	ChicharrÃ³n crocante tradicional, especialidad de los restaurantes de Filandia.	3003030303	/gastronomia/CHICHARRON_FILANDIA.webp
63	4	Plato de gastronomÃ­a asiÃ¡tica oriental, oferta gastronÃ³mica moderna en Filandia.	3003030303	/gastronomia/ASIATICO_FILANDIA.jpg
70	33	Viudo de pescado tradicional, preparado al vapor con plÃ¡tano y yuca.	3008080808	/gastronomia/VIUDO_DESIERTO.png
71	33	Tamal huilense tradicional envuelto en hoja de plÃ¡tano.	3008080808	/gastronomia/TAMAL_DESIERTO.png
72	33	Asado huilense tÃ­pico servido con arepa y plÃ¡tano maduro.	3008080808	/gastronomia/ASADO_DESIERTO.png
73	34	Arepas de choclo tradicionales con queso de la regiÃ³n.	3008080808	/gastronomia/AREPAS_RIVERA.png
74	34	Asado huilense tÃ­pico acompaÃ±ado de insulsos y arepa.	3008080808	/gastronomia/ASADO_RIVERA.png
75	34	Viudo de pescado tradicional servido con yuca y plÃ¡tano.	3008080808	/gastronomia/VIUDO_RIVERA.png
76	35	Patacones crujientes servidos con guacamole y ahogado tradicional.	3003030303	/gastronomia/PATACONES_PARQUECAFE.png
77	35	Plato tÃ­pico paisa completo con frÃ­joles, chicharrÃ³n, chorizo y acompaÃ±amientos.	3003030303	/gastronomia/PAISA_PARQUECAFE.png
78	35	ChicharrÃ³n crocante acompaÃ±ado de limÃ³n y arepa.	3003030303	/gastronomia/CHICHARRON_PARQUECAFE.png
79	3	Sopa tradicional artesanal, un plato reconfortante tÃ­pico de Salento.	3003030303	/gastronomia/SOPA_SALENTO.jpg
80	36	Sopa tradicional santandereana preparada con variadas carnes, maÃ­z y verduras.	3006060606	/gastronomia/MUTE_SANGIL.png
81	36	Pepitoria santandereana plato autÃ³ctono elaborado a base de visceras de cabro, arroz y especias.	3006060606	/gastronomia/PEPITORIA_SANGIL.png
82	36	Hormigas culonas tostadas y saladas, pasaboca exÃ³tico e icÃ³nico de la regiÃ³n.	3006060606	/gastronomia/HORMIGAS_SANGIL.png
83	36	Cabro asado a la parrilla servido con yuca, arepa santandereana y pepitoria.	3006060606	/gastronomia/CABRO_SANGIL.png
84	37	Dulce tradicional santandereano, postre tÃ­pico de la regiÃ³n del Chicamocha.	3007070707	/gastronomia/DULCE_CHICAMOCHA.jpg
85	37	Picada tÃ­pica santandereana con variedad de carnes, morcilla y arepa.	3007070707	/gastronomia/PICADA_CHICAMOCHA.jpg
86	37	Cabrito asado acompaÃ±ado de pepitoria, yuca y arepa santandereana.	3007070707	/gastronomia/CABROO_CHICAMOCHA.jpg
87	10	Bandeja tÃ­pica de la regiÃ³n, servida con acompaÃ±amientos tradicionales.	3005050505	/gastronomia/BANDEJA_LAGOCALIMA.jpg
88	10	CÃ³ctel refrescante ideal para disfrutar en la zona turÃ­stica del lago.	3005050505	/gastronomia/COCTEL_LAGOCALIMA.jpg
89	10	Pizza artesanal horneada, opciÃ³n gastronÃ³mica popular para visitantes.	3005050505	/gastronomia/PIZZA_LAGOCALIMA.jpg
\.


--
-- Data for Name: habitacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.habitacion (id_habitacion, id_hotel, nombre, descripcion, tipo_cama, capacidad, precio, foto_referencia, activa) FROM stdin;
3	2	HabitaciÃ³n rÃºstica finca cafetera	\N	1 cama doble	2	180000.00	\N	t
4	2	CabaÃ±a doble con chimenea	\N	1 cama doble	2	260000.00	\N	t
5	3	CabaÃ±a individual de madera	\N	1 cama doble	2	140000.00	\N	t
7	4	HabitaciÃ³n colonial estÃ¡ndar	\N	1 cama doble	2	160000.00	\N	t
8	4	Suite con vista a la plaza	\N	1 cama doble	2	250000.00	\N	t
10	5	Suite con piscina privada	\N	1 cama doble	2	380000.00	\N	t
11	6	HabitaciÃ³n doble boyacense	\N	1 cama doble	2	190000.00	\N	t
13	7	HabitaciÃ³n colonial junto al rÃ­o	\N	1 cama doble	2	210000.00	\N	t
15	8	HabitaciÃ³n finca San AgustÃ­n	\N	1 cama doble	2	130000.00	\N	t
16	8	CabaÃ±a doble con vista al valle	\N	1 cama doble	2	240000.00	\N	t
309	84	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
6	3	CabaÃ±a familiar Valle de Cocora	\N	2 camas dobles	4	300000.00	\N	t
9	5	HabitaciÃ³n patio interior	\N	1 cama doble	2	200000.00	\N	t
12	6	HabitaciÃ³n familiar Villa de Leyva	\N	2 camas dobles	4	280000.00	\N	t
14	7	Suite Mompox con aljibe	\N	1 cama doble	2	320000.00	\N	t
310	84	Suite familiar	\N	2 camas dobles	4	150000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
311	84	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
312	84	HabitaciÃ³n matrimonial	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
313	85	Suite familiar	\N	2 camas dobles	4	110000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
314	85	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
1	1	HabitaciÃ³n sencilla vista al embalse	\N	1 cama doble	2	150000.00	\N	t
315	85	HabitaciÃ³n matrimonial	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
316	85	Suite con vista	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
317	86	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
318	86	HabitaciÃ³n matrimonial	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
319	86	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
320	86	HabitaciÃ³n sencilla	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
321	87	HabitaciÃ³n matrimonial	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
322	87	Suite con vista	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
323	87	HabitaciÃ³n sencilla	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
324	87	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
325	88	Suite con vista	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
326	88	HabitaciÃ³n sencilla	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
327	88	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
328	88	Suite familiar	\N	2 camas dobles	4	220000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
329	89	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
330	89	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
331	89	Suite familiar	\N	2 camas dobles	4	260000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
332	89	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
333	90	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
334	90	Suite familiar	\N	2 camas dobles	4	190000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
335	90	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
336	90	HabitaciÃ³n matrimonial	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
337	91	Suite familiar	\N	2 camas dobles	4	170000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
338	91	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
339	91	HabitaciÃ³n matrimonial	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
340	91	Suite con vista	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
341	92	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
342	92	HabitaciÃ³n matrimonial	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
343	92	Suite con vista	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
344	92	HabitaciÃ³n sencilla	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
345	93	HabitaciÃ³n matrimonial	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
346	93	Suite con vista	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
347	93	HabitaciÃ³n sencilla	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
348	93	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
349	94	Suite con vista	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
350	94	HabitaciÃ³n sencilla	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
351	94	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
352	94	Suite familiar	\N	2 camas dobles	4	150000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
2	1	HabitaciÃ³n doble con balcÃ³n	\N	1 cama doble	2	220000.00	\N	t
353	95	HabitaciÃ³n sencilla	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
354	95	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
355	95	Suite familiar	\N	2 camas dobles	4	110000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
356	95	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
357	96	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
358	96	Suite familiar	\N	2 camas dobles	4	260000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
359	96	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
360	96	HabitaciÃ³n matrimonial	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
361	97	Suite familiar	\N	2 camas dobles	4	150000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
362	97	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
363	97	HabitaciÃ³n matrimonial	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
364	97	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
365	98	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
366	98	HabitaciÃ³n matrimonial	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
367	98	Suite con vista	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
368	98	HabitaciÃ³n sencilla	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
369	99	HabitaciÃ³n matrimonial	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
370	99	Suite con vista	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
371	99	HabitaciÃ³n sencilla	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
372	99	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
373	100	Suite con vista	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
374	100	HabitaciÃ³n sencilla	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
375	100	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
376	100	Suite familiar	\N	2 camas dobles	4	170000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
377	101	HabitaciÃ³n sencilla	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
378	101	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
379	101	Suite familiar	\N	2 camas dobles	4	220000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
380	101	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
381	102	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
382	102	Suite familiar	\N	2 camas dobles	4	110000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
383	102	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
384	102	HabitaciÃ³n matrimonial	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
385	103	Suite familiar	\N	2 camas dobles	4	90000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
386	103	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
387	103	HabitaciÃ³n matrimonial	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
388	103	Suite con vista	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
389	104	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
390	104	HabitaciÃ³n matrimonial	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
711	189	HabitaciÃ³n EstÃ¡ndar Superior	\N	1 cama doble	2	210000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
712	189	Suite Ejecutiva	\N	1 cama doble	2	270000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
713	189	HabitaciÃ³n Familiar con Vista al JardÃ­n	\N	2 camas dobles	4	240000.00	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	t
714	190	HabitaciÃ³n Doble Tradicional	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80	t
715	190	HabitaciÃ³n Triple Superior	\N	3 camas sencillas	3	170000.00	https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800&q=80	t
716	191	HabitaciÃ³n CabaÃ±a con Chimenea	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
717	191	Suite PanorÃ¡mica con Vista a la Laguna	\N	1 cama doble	2	300000.00	https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800&q=80	t
718	192	HabitaciÃ³n Matrimonial RÃºstica	\N	1 cama doble	2	140000.00	https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800&q=80	t
719	192	CabaÃ±a Familiar EcolÃ³gica	\N	2 camas dobles	4	180000.00	https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80	t
720	193	HabitaciÃ³n Doble Confort	\N	1 cama doble	2	160000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
721	193	HabitaciÃ³n Familiar Premium	\N	2 camas dobles	4	200000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
722	194	HabitaciÃ³n Sencilla EstÃ¡ndar	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80	t
723	194	HabitaciÃ³n Doble Twin	\N	2 camas sencillas	2	150000.00	https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800&q=80	t
724	195	HabitaciÃ³n Superior Frente al Mar	\N	1 cama doble	2	280000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
725	195	Suite Del Mar con BalcÃ³n	\N	1 cama doble	2	340000.00	https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800&q=80	t
726	196	HabitaciÃ³n Doble Ejecutiva	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	t
727	196	Suite Familiar con Aire Acondicionado	\N	2 camas dobles	4	210000.00	https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800&q=80	t
729	197	Suite Termal Especial	\N	1 cama doble	2	460000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
730	198	CabaÃ±a Pareja con Termales	\N	1 cama doble	2	240000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
731	198	CabaÃ±a Familiar con Jacuzzi Termal	\N	2 camas dobles	4	280000.00	https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800&q=80	t
728	197	HabitaciÃ³n Standard Lake View	\N	1 cama doble	2	380000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
536	144	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
504	136	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
505	136	HabitaciÃ³n sencilla	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
506	136	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
507	136	Suite familiar	\N	2 camas dobles	4	220000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
508	137	HabitaciÃ³n sencilla	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
509	137	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
510	137	Suite familiar	\N	2 camas dobles	4	220000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
511	137	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
512	138	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
513	138	Suite familiar	\N	2 camas dobles	4	150000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
514	138	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
515	138	HabitaciÃ³n matrimonial	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
516	139	Suite familiar	\N	2 camas dobles	4	170000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
517	139	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
518	139	HabitaciÃ³n matrimonial	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
519	139	Suite con vista	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
520	140	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
521	140	HabitaciÃ³n matrimonial	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
522	140	Suite con vista	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
523	140	HabitaciÃ³n sencilla	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
524	141	HabitaciÃ³n matrimonial	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
525	141	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
526	141	HabitaciÃ³n sencilla	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
527	141	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
528	142	Suite con vista	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
529	142	HabitaciÃ³n sencilla	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
530	142	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
531	142	Suite familiar	\N	2 camas dobles	4	90000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
532	143	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
533	143	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
534	143	Suite familiar	\N	2 camas dobles	4	260000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
535	143	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
537	144	Suite familiar	\N	2 camas dobles	4	90000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
539	144	HabitaciÃ³n matrimonial	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
540	145	Suite familiar	\N	2 camas dobles	4	130000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
541	145	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
543	145	Suite con vista	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
545	146	HabitaciÃ³n matrimonial	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
546	146	Suite con vista	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
549	147	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
550	147	HabitaciÃ³n sencilla	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
551	147	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
552	148	Suite con vista	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
553	148	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
554	148	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
555	148	Suite familiar	\N	2 camas dobles	4	130000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
556	149	HabitaciÃ³n sencilla	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
557	149	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
558	149	Suite familiar	\N	2 camas dobles	4	110000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
559	149	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
560	150	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
561	150	Suite familiar	\N	2 camas dobles	4	110000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
562	150	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
563	150	HabitaciÃ³n matrimonial	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
564	151	Suite familiar	\N	2 camas dobles	4	150000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
565	151	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
566	151	HabitaciÃ³n matrimonial	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
567	151	Suite con vista	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
568	152	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
569	152	HabitaciÃ³n matrimonial	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
570	152	Suite con vista	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
571	152	HabitaciÃ³n sencilla	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
572	153	HabitaciÃ³n matrimonial	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
573	153	Suite con vista	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
574	153	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
544	146	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
542	145	HabitaciÃ³n matrimonial	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
538	144	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
548	147	HabitaciÃ³n matrimonial	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
547	146	HabitaciÃ³n sencilla	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
575	153	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
576	154	Suite con vista	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
577	154	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
578	154	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
579	154	Suite familiar	\N	2 camas dobles	4	170000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
580	155	HabitaciÃ³n sencilla	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
581	155	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
582	155	Suite familiar	\N	2 camas dobles	4	90000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
615	165	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
616	165	HabitaciÃ³n sencilla	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
617	165	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
618	165	Suite familiar	\N	2 camas dobles	4	130000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
619	166	HabitaciÃ³n sencilla	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
620	166	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
621	166	Suite familiar	\N	2 camas dobles	4	130000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
622	166	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
623	167	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
624	167	Suite familiar	\N	2 camas dobles	4	170000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
625	167	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
626	167	HabitaciÃ³n matrimonial	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
627	168	Suite familiar	\N	2 camas dobles	4	260000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
628	168	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
629	168	HabitaciÃ³n matrimonial	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
630	168	Suite con vista	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
631	169	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
632	169	HabitaciÃ³n matrimonial	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
633	169	Suite con vista	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
634	169	HabitaciÃ³n sencilla	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
635	170	HabitaciÃ³n matrimonial	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
636	170	Suite con vista	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
637	170	HabitaciÃ³n sencilla	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
638	170	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
639	171	Suite con vista	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
640	171	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
641	171	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
642	171	Suite familiar	\N	2 camas dobles	4	110000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
643	172	HabitaciÃ³n sencilla	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
644	172	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
645	172	Suite familiar	\N	2 camas dobles	4	110000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
646	172	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
647	173	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
648	173	Suite familiar	\N	2 camas dobles	4	220000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
649	173	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
650	173	HabitaciÃ³n matrimonial	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
651	174	Suite familiar	\N	2 camas dobles	4	190000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
652	174	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
653	174	HabitaciÃ³n matrimonial	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
654	174	Suite con vista	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
655	175	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
656	175	HabitaciÃ³n matrimonial	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
657	175	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
658	175	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
659	176	HabitaciÃ³n matrimonial	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
660	176	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
661	176	HabitaciÃ³n sencilla	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
662	176	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
663	177	Suite con vista	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
664	177	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
665	177	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
666	177	Suite familiar	\N	2 camas dobles	4	220000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
667	178	HabitaciÃ³n sencilla	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
668	178	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
669	178	Suite familiar	\N	2 camas dobles	4	260000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
670	178	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
671	179	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
672	179	Suite familiar	\N	2 camas dobles	4	130000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
673	179	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
674	179	HabitaciÃ³n matrimonial	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
675	180	Suite familiar	\N	2 camas dobles	4	190000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
676	180	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
677	180	HabitaciÃ³n matrimonial	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
678	180	Suite con vista	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
679	181	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
680	181	HabitaciÃ³n matrimonial	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
681	181	Suite con vista	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
682	181	HabitaciÃ³n sencilla	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
683	182	HabitaciÃ³n matrimonial	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
684	182	Suite con vista	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
685	182	HabitaciÃ³n sencilla	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
686	182	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
687	183	Suite con vista	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
688	183	HabitaciÃ³n sencilla	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
689	183	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
690	183	Suite familiar	\N	2 camas dobles	4	220000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
691	184	HabitaciÃ³n sencilla	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
692	184	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	90000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
693	184	Suite familiar	\N	2 camas dobles	4	150000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
694	184	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	110000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
695	185	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
696	185	HabitaciÃ³n matrimonial	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
697	185	Suite con vista	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
698	185	HabitaciÃ³n sencilla	\N	1 cama doble	2	130000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
699	186	HabitaciÃ³n sencilla	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80	t
700	186	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
701	186	Suite familiar	\N	2 camas dobles	4	260000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
702	186	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
703	187	HabitaciÃ³n doble estÃ¡ndar	\N	1 cama doble	2	150000.00	https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80	t
704	187	Suite familiar	\N	2 camas dobles	4	220000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
705	187	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
706	187	HabitaciÃ³n matrimonial	\N	1 cama doble	2	170000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
707	188	Suite familiar	\N	2 camas dobles	4	260000.00	https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80	t
708	188	HabitaciÃ³n con balcÃ³n	\N	1 cama doble	2	220000.00	https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80	t
709	188	HabitaciÃ³n matrimonial	\N	1 cama doble	2	190000.00	https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80	t
710	188	Suite con vista	\N	1 cama doble	2	260000.00	https://images.unsplash.com/photo-1611892441198-45b1a0a3b7f4?w=800&q=80	t
\.


--
-- Data for Name: hotel; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hotel (id_hotel, id_destino, id_propietario, nombre, foto_referencia, direccion, descripcion, contacto, categoria, politicas, activo, fecha_registro, id_solicitud) FROM stdin;
138	10	\N	Posada Lago Calima	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	Calle Principal #8-20, Lago Calima	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
2	2	\N	Posada Cafetera JardÃ­n	hotel2.jpg	Cra 3 #8-10, JardÃ­n	Posada rÃºstica dentro de una finca cafetera a las afueras del pueblo.	\N	\N	\N	t	2026-08-20 21:21:04.432456	\N
84	2	\N	Posada JardÃ­n	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	Calle Principal #8-20, JardÃ­n	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
1	1	\N	Hostal Vista PeÃ±ol	hotel1.jpg	Cl Principal #12-30, GuatapÃ©	Hostal familiar con vista al embalse y zÃ³calos tÃ­picos.	\N	\N	\N	t	2026-08-20 21:21:04.432456	\N
4	4	\N	Casa Colina Filandia	hotel4.jpg	Cl 7 #5-22, Filandia	Casa colonial restaurada con balcÃ³n sobre la plaza principal.	\N	\N	\N	t	2026-08-20 21:21:04.432456	\N
139	10	\N	Hostal Central Lago Calima	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	VÃ­a rural km 2, Lago Calima	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
85	2	\N	Hostal Central JardÃ­n	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	VÃ­a rural km 2, JardÃ­n	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
189	9	\N	Hotel Guadalajara de Buga	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Calle 1 # 13-33, Buga	Hotel icÃ³nico con arquitectura colonial, amplias zonas verdes y piscina.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
165	32	\N	Refugio El Cocuy	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Cra 6 #10-15, centro de El Cocuy	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
191	15	\N	Chalet Suizo Sindamanoy	https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80	Vereda El Encano, Laguna La Cocha	Refugio de montaÃ±a estilo suizo frente a las frÃ­as aguas de la laguna.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
140	11	\N	Refugio Buenaventura	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Cra 6 #10-15, centro de Buenaventura	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
190	9	\N	Hotel San Fernando Buga	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Carrera 13 # 4-50, Buga	Hospedaje acogedor ubicado a pocos pasos del centro histÃ³rico y la basÃ­lica.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
8	8	\N	Finca Hostal San AgustÃ­n	hotel8.jpg	VÃ­a Parque ArqueolÃ³gico Km 3	Finca hostal rodeada de naturaleza, cerca a las estatuas precolombinas.	\N	\N	\N	t	2026-08-20 21:21:04.432456	\N
3	3	\N	Hostal Valle de Cocora	hotel3.jpg	VÃ­a Salento - Cocora Km 2	CabaÃ±as de madera cerca al valle, ideal para caminantes.	\N	\N	\N	t	2026-08-20 21:21:04.432456	\N
5	5	\N	Hotel Casona Barichara	hotel5.jpg	Cl 6 #6-30, Barichara	Casona de tapia pisada con patio interior y piscina.	\N	\N	\N	t	2026-08-20 21:21:04.432456	\N
6	6	\N	Hostal Colonial Leyva	hotel6.jpg	Cra 9 #12-18, Villa de Leyva	A dos cuadras de la plaza mayor, decoraciÃ³n tÃ­pica boyacense.	\N	\N	\N	t	2026-08-20 21:21:04.432456	\N
166	32	\N	Casa Colonial El Cocuy	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Calle 5 #3-40, El Cocuy	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
7	7	\N	Hotel Portal de Mompox	hotel7.jpg	Cl del Medio #4-15, Mompox	Hotel colonial junto al rÃ­o Magdalena, patio con aljibe.	\N	\N	\N	t	2026-08-20 21:21:04.432456	\N
86	2	\N	Refugio JardÃ­n	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Cra 6 #10-15, centro de JardÃ­n	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
87	2	\N	Casa Colonial JardÃ­n	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Calle 5 #3-40, JardÃ­n	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
192	15	\N	Hostal Campestre La Cocha	https://images.unsplash.com/photo-1587061949409-02df41d5e562?w=800&q=80	Sector Embarcadero, El Encano	Alojamiento rÃºstico ideal para conectar con la naturaleza de la regiÃ³n.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
141	11	\N	Casa Colonial Buenaventura	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Calle 5 #3-40, Buenaventura	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
167	32	\N	Finca Hotel El Cocuy	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	Cra 3 #4-12, El Cocuy	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
88	3	\N	Finca Hotel Salento	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Cra 3 #4-12, Salento	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
193	16	\N	Hotel Loft Las Lajas	https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80	Carrera 6 # 14-25, Ipiales	Hotel moderno y cÃ³modo a poca distancia del famoso Santuario.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
142	11	\N	Finca Hotel Buenaventura	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Cra 3 #4-12, Buenaventura	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
89	3	\N	Mirador de Salento	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Calle Principal #8-20, Salento	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
168	32	\N	Mirador de El Cocuy	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	Calle Principal #8-20, El Cocuy	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
194	16	\N	Hotel Mayasquer	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Avenida Panamericana, Ipiales	Hospedaje tradicional de fÃ¡cil acceso para turistas y peregrinos.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
195	17	\N	Hotel Resort Isla del Morro	https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800&q=80	Playa El Morro, Tumaco	Resort frente al Mar PacÃ­fico con acceso directo a la playa.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
196	17	\N	Hotel Portete Tumaco	https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80	Calle Comercio # 8-12, Tumaco	Ubicado en el centro comercial y gastronÃ³mico de Tumaco.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
143	11	\N	Mirador de Buenaventura	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Calle Principal #8-20, Buenaventura	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
90	3	\N	Hostal del Viajero Salento	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	VÃ­a rural km 2, Salento	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
103	7	\N	Hotel Mompox	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	Cra 3 #4-12, Mompox	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
169	33	\N	Hostal del Viajero Desierto de Tatacoa	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	VÃ­a rural km 2, Desierto de Tatacoa	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
91	3	\N	Villa Salento	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	Cra 6 #10-15, centro de Salento	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
92	4	\N	CabaÃ±as Filandia	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Calle 5 #3-40, Filandia	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
170	33	\N	Villa Desierto de Tatacoa	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Cra 6 #10-15, centro de Desierto de Tatacoa	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
198	31	\N	CabaÃ±as Termales Sochagota	https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80	Calle 25 # 5-10, Paipa	CabaÃ±as privadas con piscinas termales naturales para relajaciÃ³n total.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
93	4	\N	Hotel Filandia	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Cra 3 #4-12, Filandia	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
145	28	\N	Villa Santa Fe de Antioquia	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	Cra 6 #10-15, centro de Santa Fe de Antioquia	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
144	28	\N	Hostal del Viajero Santa Fe de Antioquia	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	VÃ­a rural km 2, Santa Fe de Antioquia	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
197	31	\N	Hotel Estelar Paipa Hotel & Spa	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	KilÃ³metro 4 VÃ­a Pantano de Vargas, Paipa	Hotel de lujo con circuito termal, spa y vista al lago Sochagota.	\N	\N	\N	t	2026-09-13 12:00:33.725263	\N
171	33	\N	CabaÃ±as Desierto de Tatacoa	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Calle 5 #3-40, Desierto de Tatacoa	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
94	4	\N	Posada Filandia	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Calle Principal #8-20, Filandia	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
136	10	\N	CabaÃ±as Lago Calima	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Calle 5 #3-40, Lago Calima	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
95	4	\N	Hostal Central Filandia	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	VÃ­a rural km 2, Filandia	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
172	33	\N	Hotel Desierto de Tatacoa	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Cra 3 #4-12, Desierto de Tatacoa	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
96	5	\N	Refugio Barichara	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	Cra 6 #10-15, centro de Barichara	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
137	10	\N	Hotel Lago Calima	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Cra 3 #4-12, Lago Calima	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
173	34	\N	Posada Rivera	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	Calle Principal #8-20, Rivera	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
97	5	\N	Casa Colonial Barichara	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	Calle 5 #3-40, Barichara	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
147	28	\N	Hotel Santa Fe de Antioquia	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Cra 3 #4-12, Santa Fe de Antioquia	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
146	28	\N	CabaÃ±as Santa Fe de Antioquia	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Calle 5 #3-40, Santa Fe de Antioquia	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
98	5	\N	Finca Hotel Barichara	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Cra 3 #4-12, Barichara	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
174	34	\N	Hostal Central Rivera	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	VÃ­a rural km 2, Rivera	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
99	6	\N	Mirador de Villa de Leyva	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Calle Principal #8-20, Villa de Leyva	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
175	34	\N	Refugio Rivera	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Cra 6 #10-15, centro de Rivera	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
148	29	\N	Posada Cartagena de Indias	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Calle Principal #8-20, Cartagena de Indias	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
100	6	\N	Hostal del Viajero Villa de Leyva	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	VÃ­a rural km 2, Villa de Leyva	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
176	34	\N	Casa Colonial Rivera	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Calle 5 #3-40, Rivera	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
101	6	\N	Villa Villa de Leyva	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Cra 6 #10-15, centro de Villa de Leyva	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
149	29	\N	Hostal Central Cartagena de Indias	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	VÃ­a rural km 2, Cartagena de Indias	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
102	7	\N	CabaÃ±as Mompox	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	Calle 5 #3-40, Mompox	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
177	35	\N	Finca Hotel Parque de CafÃ©	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Cra 3 #4-12, Parque de CafÃ©	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
150	29	\N	Refugio Cartagena de Indias	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	Cra 6 #10-15, centro de Cartagena de Indias	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
178	35	\N	Mirador de Parque de CafÃ©	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Calle Principal #8-20, Parque de CafÃ©	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
104	7	\N	Posada Mompox	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Calle Principal #8-20, Mompox	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-04 06:55:41.151311	\N
151	29	\N	Casa Colonial Cartagena de Indias	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	Calle 5 #3-40, Cartagena de Indias	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
179	35	\N	Hostal del Viajero Parque de CafÃ©	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	VÃ­a rural km 2, Parque de CafÃ©	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
152	30	\N	Finca Hotel San Basilio de Palenque	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Cra 3 #4-12, San Basilio de Palenque	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
153	30	\N	Mirador de San Basilio de Palenque	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Calle Principal #8-20, San Basilio de Palenque	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
180	35	\N	Villa Parque de CafÃ©	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	Cra 6 #10-15, centro de Parque de CafÃ©	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
181	36	\N	CabaÃ±as San Gil	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Calle 5 #3-40, San Gil	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
154	30	\N	Hostal del Viajero San Basilio de Palenque	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	VÃ­a rural km 2, San Basilio de Palenque	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
155	30	\N	Villa San Basilio de Palenque	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	Cra 6 #10-15, centro de San Basilio de Palenque	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:20:37.063987	\N
182	36	\N	Hotel San Gil	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Cra 3 #4-12, San Gil	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
183	36	\N	Posada San Gil	https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80	Calle Principal #8-20, San Gil	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
184	36	\N	Hostal Central San Gil	https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80	VÃ­a rural km 2, San Gil	ConstrucciÃ³n tradicional con toques modernos, atenciÃ³n personalizada.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
185	37	\N	Refugio Chicamocha	https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80	Cra 6 #10-15, centro de Chicamocha	Rodeado de naturaleza, perfecto para desconectarse.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
186	37	\N	Casa Colonial Chicamocha	https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80	Calle 5 #3-40, Chicamocha	UbicaciÃ³n cÃ©ntrica, cerca de restaurantes y sitios turÃ­sticos.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
187	37	\N	Finca Hotel Chicamocha	https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80	Cra 3 #4-12, Chicamocha	Alojamiento acogedor cerca del centro, ideal para descansar.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
188	37	\N	Mirador de Chicamocha	https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80	Calle Principal #8-20, Chicamocha	Vistas privilegiadas y ambiente tranquilo, a pocos minutos de las principales atracciones.	\N	\N	\N	t	2026-09-13 11:32:00.628519	\N
\.


--
-- Data for Name: solicitud_admin; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.solicitud_admin (id_solicitud, nombre, apellidos, documento, cargo, correo, telefono, password_hash, nombre_hotel, direccion_hotel, contacto_hotel, categoria, descripcion, politicas, id_destino, estado, fecha_registro, fecha_resolucion, resuelta_por, motivo_rechazo) FROM stdin;
1	Laura Alejandra	GutiÃ©rrez BolaÃ±os	1025540189	Propietario	lauralejagutierrezbolanos31@gmail.com	2541256	$2b$12$CxfNIthTmzEUNXCmliv0Q./aW.KmvRAstOS.Z2pxbmBQeMedYDqUa	vista al mar 	cll 76 f sur n 5-87 este	5456241	Hostal Tradicional	un hotel vista al m,ar; todo incluido 	no se aceptan mascotas 	29	pendiente	2026-10-24 23:02:47.544064	\N	\N	\N
\.


--
-- Data for Name: transporte; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transporte (id_transporte, id_destino, descripcion, contacto, foto_referencia) FROM stdin;
1	1	Buses desde el Terminal del Norte de MedellÃ­n, 1h15 aprox.	3001112233	\N
2	2	Buses desde MedellÃ­n (Terminal Sur) o Andes, 3h30 aprox.	3002223344	\N
3	3	Buses desde Armenia o Pereira, 45 min. Jeeps Willys al Valle de Cocora.	3003334455	\N
4	4	Buses desde Armenia, 30 min aprox.	3004445566	\N
5	5	Buses desde San Gil o Bucaramanga, 1h aprox.	3005556677	\N
6	6	Buses desde Tunja o BogotÃ¡, 3h aprox.	3006667788	\N
7	7	Buses desde Cartagena vÃ­a MaganguÃ©, 4h con cruce en ferry.	3007778899	\N
8	8	Buses desde Neiva o Pitalito, 3h aprox.	3008889900	\N
9	9	Buses directos desde el Terminal de Cali o Palmira, 1h aprox.	3009990011	\N
10	10	Buses o chivas desde Buga o DariÃ©n, 1h30 aprox.	3001010101	\N
11	11	Buses desde Cali por la vÃ­a al Mar, 2h30 aprox.	3001111111	\N
12	15	Lanchas desde el embarcadero de El Encano o buses desde Pasto, 40 min.	3001515151	\N
13	16	Taxis colectivos o buses desde el Terminal de Ipiales, 20 min.	3001616161	\N
14	17	Buses desde Pasto o vuelos directos al Aeropuerto La Florida.	3001717171	\N
15	28	Buses desde el Terminal del Norte de MedellÃ­n por el TÃºnel de Occidente, 1h.	3002828282	\N
16	29	Vuelos directos al Aeropuerto Rafael NÃºÃ±ez o buses intermunicipales.	3002929292	\N
17	30	Buses o chivas intermunicipales desde el Terminal de Cartagena, 1h30.	3003030303	\N
18	31	Buses desde Tunja o Duitama, 45 min aprox.	3003131313	\N
19	32	Buses desde Tunja hasta la cabecera municipal de El Cocuy, 8h aprox.	3003232323	\N
20	33	Camionetas 4x4 o mototaxis desde Villavieja o Neiva, 45 min.	3003333333	\N
21	34	Buses urbanos o taxis intermunicipales desde el Terminal de Neiva, 20 min.	3003434343	\N
22	35	Buses urbanos desde el Terminal de Armenia o Montenegro, 30 min.	3003535353	\N
23	36	Buses directos desde Bucaramanga o BogotÃ¡ (Terminal Salitre), 2h30 desde Bucaramanga.	3003636363	\N
24	37	Buses desde Bucaramanga vÃ­a San Gil o telefÃ©rico desde la EstaciÃ³n Mesa de los Santos.	3003737373	\N
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usuario (id_usuario, nombre, apellidos, ciudad, direccion, correo, telefono, documento, rol, password_hash, activo, fecha_registro) FROM stdin;
1	martin	\N	\N	\N	admin2@gmail.com	\N	\N	super_admin	$2b$12$Fd5RvMNb21Etmbto7awA0endCtESfbvpszHPJrOAIl11oBXUQIPNW	t	2026-10-24 20:57:59.705312
2	laura	bolaÃ±os	string	string	user@example.com	string	\N	usuario	$2b$12$a53Zk.3CEgIAZQC7Np2i9eMhAxg8KkEGti2oApOGuFz5hCuBIfrxu	t	2026-10-24 21:03:28.427775
3	Alejandra	GutiÃ©rrez 	bogota	7tg8y	lauraguti@gmail.com	325416786	\N	usuario	$2b$12$klvglHdo1Nl2g60VSlGoSe9rCGiTQzeAEp5tIaSqLULxCt28eycuG	t	2026-10-24 23:30:46.603644
4	lina	Carrillo	medellin	cll 76 	lina@gmail.com	3254125689	\N	usuario	$2b$12$PBFVPztu8mXbjvxmzSpXpud7JbJXYdwozKPXjPd8xzcA14cMzP.1y	t	2026-10-25 02:30:43.664438
\.


--
-- Data for Name: viaje_habitacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.viaje_habitacion (id_vh, id_vp, id_habitacion, personas_asignadas, precio_noche, fechas, activa) FROM stdin;
1	1	1	2	150000.00	[2026-11-10,2026-11-13)	f
2	1	2	1	220000.00	[2026-11-10,2026-11-13)	f
3	2	317	2	90000.00	[2026-10-24,2026-10-25)	f
4	3	321	2	90000.00	[2026-10-24,2026-10-26)	t
5	4	1	1	150000.00	[2026-10-26,2026-10-28)	t
\.


--
-- Data for Name: viaje_personalizado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.viaje_personalizado (id_vp, id_usuario, id_destino, id_hotel, fecha_inicial, fecha_final, num_personas, precio, estado, fecha_registro) FROM stdin;
1	1	1	1	2026-11-10	2026-11-13	3	1110000.00	cancelado	2026-10-24 22:05:09.540537
2	3	2	86	2026-10-24	2026-10-25	2	90000.00	cancelado	2026-10-24 23:31:14.616869
3	3	2	87	2026-10-24	2026-10-26	2	180000.00	reservado	2026-10-24 23:31:44.303394
4	4	1	1	2026-10-26	2026-10-28	1	300000.00	reservado	2026-10-25 02:31:18.505247
\.


--
-- Name: actividades_id_actividades_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.actividades_id_actividades_seq', 72, true);


--
-- Name: deptos_id_depto_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deptos_id_depto_seq', 8, true);


--
-- Name: destinos_id_destino_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.destinos_id_destino_seq', 37, true);


--
-- Name: ferias_id_feria_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ferias_id_feria_seq', 4, true);


--
-- Name: gastronomia_id_gastronomia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.gastronomia_id_gastronomia_seq', 89, true);


--
-- Name: habitacion_id_habitacion_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.habitacion_id_habitacion_seq', 731, true);


--
-- Name: hotel_id_hotel_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hotel_id_hotel_seq', 198, true);


--
-- Name: solicitud_admin_id_solicitud_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.solicitud_admin_id_solicitud_seq', 1, true);


--
-- Name: transporte_id_transporte_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transporte_id_transporte_seq', 24, true);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 4, true);


--
-- Name: viaje_habitacion_id_vh_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.viaje_habitacion_id_vh_seq', 5, true);


--
-- Name: viaje_personalizado_id_vp_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.viaje_personalizado_id_vp_seq', 4, true);


--
-- Name: actividades actividades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividades
    ADD CONSTRAINT actividades_pkey PRIMARY KEY (id_actividades);


--
-- Name: deptos deptos_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deptos
    ADD CONSTRAINT deptos_nombre_key UNIQUE (nombre);


--
-- Name: deptos deptos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deptos
    ADD CONSTRAINT deptos_pkey PRIMARY KEY (id_depto);


--
-- Name: destinos destinos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinos
    ADD CONSTRAINT destinos_pkey PRIMARY KEY (id_destino);


--
-- Name: ferias ferias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ferias
    ADD CONSTRAINT ferias_pkey PRIMARY KEY (id_feria);


--
-- Name: gastronomia gastronomia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gastronomia
    ADD CONSTRAINT gastronomia_pkey PRIMARY KEY (id_gastronomia);


--
-- Name: habitacion habitacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.habitacion
    ADD CONSTRAINT habitacion_pkey PRIMARY KEY (id_habitacion);


--
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (id_hotel);


--
-- Name: viaje_habitacion sin_cruce_fechas; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_habitacion
    ADD CONSTRAINT sin_cruce_fechas EXCLUDE USING gist (id_habitacion WITH =, fechas WITH &&) WHERE (activa);


--
-- Name: solicitud_admin solicitud_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitud_admin
    ADD CONSTRAINT solicitud_admin_pkey PRIMARY KEY (id_solicitud);


--
-- Name: transporte transporte_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transporte
    ADD CONSTRAINT transporte_pkey PRIMARY KEY (id_transporte);


--
-- Name: usuario usuario_correo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_correo_key UNIQUE (correo);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: viaje_habitacion viaje_habitacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_habitacion
    ADD CONSTRAINT viaje_habitacion_pkey PRIMARY KEY (id_vh);


--
-- Name: viaje_personalizado viaje_personalizado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_personalizado
    ADD CONSTRAINT viaje_personalizado_pkey PRIMARY KEY (id_vp);


--
-- Name: idx_activ_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activ_destino ON public.actividades USING btree (id_destino);


--
-- Name: idx_destinos_depto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_destinos_depto ON public.destinos USING btree (id_depto);


--
-- Name: idx_gastro_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gastro_destino ON public.gastronomia USING btree (id_destino);


--
-- Name: idx_habitacion_hotel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_habitacion_hotel ON public.habitacion USING btree (id_hotel);


--
-- Name: idx_hotel_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hotel_destino ON public.hotel USING btree (id_destino);


--
-- Name: idx_trans_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trans_destino ON public.transporte USING btree (id_destino);


--
-- Name: idx_vh_vp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vh_vp ON public.viaje_habitacion USING btree (id_vp);


--
-- Name: idx_vp_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vp_usuario ON public.viaje_personalizado USING btree (id_usuario);


--
-- Name: ux_solicitud_pendiente; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_solicitud_pendiente ON public.solicitud_admin USING btree (lower((correo)::text)) WHERE (estado = 'pendiente'::public.estado_solicitud);


--
-- Name: v_hotel _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.v_hotel AS
 SELECT h.id_hotel,
    h.id_destino,
    h.id_propietario,
    h.nombre,
    h.foto_referencia,
    h.direccion,
    h.descripcion,
    h.contacto,
    h.categoria,
    h.politicas,
    h.activo,
    h.fecha_registro,
    count(v.id_habitacion) AS total_habitaciones,
    COALESCE(round(avg(v.precio), 0), (0)::numeric) AS precio_promedio,
    count(*) FILTER (WHERE v.ocupada) AS habitaciones_ocupadas,
        CASE
            WHEN (count(v.id_habitacion) = 0) THEN (0)::numeric
            ELSE round(((100.0 * (count(*) FILTER (WHERE v.ocupada))::numeric) / (count(v.id_habitacion))::numeric), 2)
        END AS porcentaje_ocupacion
   FROM (public.hotel h
     LEFT JOIN public.v_habitacion v ON ((v.id_hotel = h.id_hotel)))
  WHERE h.activo
  GROUP BY h.id_hotel;


--
-- Name: viaje_personalizado trg_sync_habitaciones; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_sync_habitaciones AFTER UPDATE OF estado ON public.viaje_personalizado FOR EACH ROW EXECUTE FUNCTION public.sincronizar_habitaciones_viaje();


--
-- Name: viaje_habitacion trg_validar_capacidad; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validar_capacidad BEFORE INSERT OR UPDATE ON public.viaje_habitacion FOR EACH ROW EXECUTE FUNCTION public.validar_capacidad_habitacion();


--
-- Name: actividades actividades_id_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividades
    ADD CONSTRAINT actividades_id_destino_fkey FOREIGN KEY (id_destino) REFERENCES public.destinos(id_destino) ON DELETE CASCADE;


--
-- Name: destinos destinos_id_depto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinos
    ADD CONSTRAINT destinos_id_depto_fkey FOREIGN KEY (id_depto) REFERENCES public.deptos(id_depto) ON DELETE CASCADE;


--
-- Name: ferias ferias_id_depto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ferias
    ADD CONSTRAINT ferias_id_depto_fkey FOREIGN KEY (id_depto) REFERENCES public.deptos(id_depto) ON DELETE SET NULL;


--
-- Name: ferias ferias_id_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ferias
    ADD CONSTRAINT ferias_id_destino_fkey FOREIGN KEY (id_destino) REFERENCES public.destinos(id_destino) ON DELETE SET NULL;


--
-- Name: gastronomia gastronomia_id_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gastronomia
    ADD CONSTRAINT gastronomia_id_destino_fkey FOREIGN KEY (id_destino) REFERENCES public.destinos(id_destino) ON DELETE CASCADE;


--
-- Name: habitacion habitacion_id_hotel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.habitacion
    ADD CONSTRAINT habitacion_id_hotel_fkey FOREIGN KEY (id_hotel) REFERENCES public.hotel(id_hotel) ON DELETE CASCADE;


--
-- Name: hotel hotel_id_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT hotel_id_destino_fkey FOREIGN KEY (id_destino) REFERENCES public.destinos(id_destino) ON DELETE CASCADE;


--
-- Name: hotel hotel_id_propietario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT hotel_id_propietario_fkey FOREIGN KEY (id_propietario) REFERENCES public.usuario(id_usuario) ON DELETE SET NULL;


--
-- Name: hotel hotel_id_solicitud_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT hotel_id_solicitud_fkey FOREIGN KEY (id_solicitud) REFERENCES public.solicitud_admin(id_solicitud) ON DELETE SET NULL;


--
-- Name: solicitud_admin solicitud_admin_id_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitud_admin
    ADD CONSTRAINT solicitud_admin_id_destino_fkey FOREIGN KEY (id_destino) REFERENCES public.destinos(id_destino);


--
-- Name: solicitud_admin solicitud_admin_resuelta_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitud_admin
    ADD CONSTRAINT solicitud_admin_resuelta_por_fkey FOREIGN KEY (resuelta_por) REFERENCES public.usuario(id_usuario) ON DELETE SET NULL;


--
-- Name: transporte transporte_id_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transporte
    ADD CONSTRAINT transporte_id_destino_fkey FOREIGN KEY (id_destino) REFERENCES public.destinos(id_destino) ON DELETE CASCADE;


--
-- Name: viaje_habitacion viaje_habitacion_id_habitacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_habitacion
    ADD CONSTRAINT viaje_habitacion_id_habitacion_fkey FOREIGN KEY (id_habitacion) REFERENCES public.habitacion(id_habitacion);


--
-- Name: viaje_habitacion viaje_habitacion_id_vp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_habitacion
    ADD CONSTRAINT viaje_habitacion_id_vp_fkey FOREIGN KEY (id_vp) REFERENCES public.viaje_personalizado(id_vp) ON DELETE CASCADE;


--
-- Name: viaje_personalizado viaje_personalizado_id_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_personalizado
    ADD CONSTRAINT viaje_personalizado_id_destino_fkey FOREIGN KEY (id_destino) REFERENCES public.destinos(id_destino);


--
-- Name: viaje_personalizado viaje_personalizado_id_hotel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_personalizado
    ADD CONSTRAINT viaje_personalizado_id_hotel_fkey FOREIGN KEY (id_hotel) REFERENCES public.hotel(id_hotel);


--
-- Name: viaje_personalizado viaje_personalizado_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viaje_personalizado
    ADD CONSTRAINT viaje_personalizado_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict glS1sYZFCs2N86QXs1LsgzwnbHkZEWGwsSVr7Zvx8qBjeH58x0vAiLvhXls75G2

