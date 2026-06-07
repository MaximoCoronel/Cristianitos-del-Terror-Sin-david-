-- ═══════════════════════════════════════════════════════════════════════════
--  FOODGO — Base de datos completa
--  Versión: 2.0
--  Ejecutar: mysql -u root -p < database.sql
-- ═══════════════════════════════════════════════════════════════════════════

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- ─────────────────────────────────────────────────────────────────────────
--  BASE DE DATOS
-- ─────────────────────────────────────────────────────────────────────────
DROP DATABASE IF EXISTS foodgo_db;
CREATE DATABASE foodgo_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE foodgo_db;

-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 1 — USUARIOS
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE usuarios (
  id            INT          UNSIGNED NOT NULL AUTO_INCREMENT,
  -- Datos personales
  nombre        VARCHAR(80)  NOT NULL,
  username      VARCHAR(50)  NOT NULL                    COMMENT 'Nombre de usuario único',
  email         VARCHAR(150) NOT NULL,
  password      VARCHAR(255) NOT NULL                    COMMENT 'Hash bcrypt',
  telefono      VARCHAR(20)  DEFAULT NULL,
  avatar        VARCHAR(255) DEFAULT NULL                COMMENT 'Ruta de imagen de perfil',
  -- Control
  rol           ENUM('cliente','admin') DEFAULT 'cliente',
  activo        TINYINT(1)   DEFAULT 1,
  ultimo_acceso DATETIME     NULL,
  created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_username (username),
  UNIQUE KEY uq_email    (email),
  INDEX idx_rol          (rol)
) ENGINE=InnoDB COMMENT='Cuentas de usuario de la plataforma';


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 2 — CATÁLOGOS
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE categorias (
  id          INT         UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(60) NOT NULL,
  icono       VARCHAR(10) NOT NULL            COMMENT 'Emoji representativo',
  descripcion VARCHAR(200) DEFAULT NULL,
  activa      TINYINT(1)  DEFAULT 1,

  PRIMARY KEY (id)
) ENGINE=InnoDB COMMENT='Categorías de tipo de cocina';


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 3 — RESTAURANTES
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE restaurantes (
  id              INT           UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(120)  NOT NULL,
  descripcion     TEXT          DEFAULT NULL      COMMENT 'Descripción larga del restaurante',
  categoria_id    INT           UNSIGNED DEFAULT NULL,
  imagen          VARCHAR(255)  DEFAULT NULL      COMMENT 'Imagen principal',

  -- ── Ubicación ──────────────────────────────────────────────────────────
  direccion       VARCHAR(255)  DEFAULT NULL,
  colonia         VARCHAR(100)  DEFAULT NULL,
  ciudad          VARCHAR(80)   DEFAULT NULL,
  estado_mx       VARCHAR(80)   DEFAULT NULL      COMMENT 'Estado de la república',
  cp              VARCHAR(10)   DEFAULT NULL      COMMENT 'Código postal',
  latitud         DECIMAL(10,7) DEFAULT NULL      COMMENT 'Para mapas',
  longitud        DECIMAL(10,7) DEFAULT NULL      COMMENT 'Para mapas',
  maps_url        VARCHAR(500)  DEFAULT NULL      COMMENT 'Link directo a Google Maps',

  -- ── Contacto ───────────────────────────────────────────────────────────
  telefono        VARCHAR(20)   DEFAULT NULL,
  whatsapp        VARCHAR(20)   DEFAULT NULL,
  email           VARCHAR(150)  DEFAULT NULL,
  sitio_web       VARCHAR(255)  DEFAULT NULL,
  instagram       VARCHAR(100)  DEFAULT NULL,
  facebook        VARCHAR(100)  DEFAULT NULL,

  -- ── Operación ──────────────────────────────────────────────────────────
  horario         VARCHAR(150)  DEFAULT NULL      COMMENT 'Texto libre: Lun-Vie 12:00-23:00',
  tiempo_entrega  SMALLINT      DEFAULT 30        COMMENT 'Minutos estimados de entrega',
  costo_envio     DECIMAL(6,2)  DEFAULT 0.00,
  pedido_minimo   DECIMAL(8,2)  DEFAULT 0.00,
  acepta_reservas TINYINT(1)    DEFAULT 1,
  capacidad       SMALLINT      DEFAULT NULL      COMMENT 'Personas máximo en reservas',

  -- ── Calificación (calculada por triggers) ──────────────────────────────
  calificacion    DECIMAL(3,1)  DEFAULT 0.0,
  total_resenas   INT           DEFAULT 0,

  -- ── Flags ──────────────────────────────────────────────────────────────
  tendencia       TINYINT(1)    DEFAULT 0,
  verificado      TINYINT(1)    DEFAULT 0         COMMENT 'Restaurante verificado por FoodGo',
  activo          TINYINT(1)    DEFAULT 1,
  created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_categoria   (categoria_id),
  INDEX idx_ciudad      (ciudad),
  INDEX idx_calificacion(calificacion),
  INDEX idx_tendencia   (tendencia),
  INDEX idx_activo      (activo),
  FULLTEXT idx_busqueda (nombre, descripcion),

  CONSTRAINT fk_rest_categoria
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Restaurantes registrados en la plataforma';

INSERT INTO `restaurantes` (`id`, `nombre`, `descripcion`, `categoria_id`, `imagen`, `direccion`, `colonia`, `ciudad`, `estado_mx`, `cp`, `latitud`, `longitud`, `maps_url`, `telefono`, `whatsapp`, `email`, `sitio_web`, `instagram`, `facebook`, `horario`, `tiempo_entrega`, `costo_envio`, `pedido_minimo`, `acepta_reservas`, `capacidad`, `calificacion`, `total_resenas`, `tendencia`, `verificado`, `activo`, `created_at`, `updated_at`) VALUES
(1, 'Burger Bros', 'Las mejores hamburguesas artesanales de Culiacán. Carne angus 100% fresca, nunca congelada. Cada burger es armada a mano con ingredientes seleccionados y pan artesanal horneado diariamente.', 1, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQ3I4mEjGz1ojyEQGcHHGm85xXTtzcYTNzkQ&s', 'Blvd. Insurgentes 1420', 'Los Pinos', 'Culiacán', 'Sinaloa', '80020', 24.7996200, -107.3879300, NULL, '667-100-1111', '6671001111', NULL, NULL, NULL, NULL, 'Lun-Dom 12:00-23:00', 25, 29.00, 150.00, 1, 60, 4.7, 3, 1, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:37:44'),
(2, 'Pizza Mia', 'Pizza italiana auténtica horneada en horno de leña. Masa madre de fermentación lenta, ingredientes importados directamente de Italia. La tradición napolitana en Culiacán.', 2, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9V0BTDiG8qjj1WQLMLlrEiSRJCXxXu32hJA&s', 'Av. Álvaro Obregón 340', 'Centro', 'Culiacán', 'Sinaloa', '80000', 24.8050100, -107.3940200, NULL, '667-200-2222', '6672002222', NULL, NULL, NULL, NULL, 'Mar-Dom 13:00-23:00', 35, 0.00, 100.00, 1, 45, 4.5, 2, 0, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:43:41'),
(3, 'Sakura Sushi', 'Sushi premium elaborado por chefs con entrenamiento en Japón. Pescado fresco de importación directo del mercado Tsukiji. Experiencia gastronómica japonesa única en el noroeste de México.', 3, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQOrqWk5t_H_93VbgXpdxsuRhBeDSCZSNyleA&s', 'Calle Ángel Flores 890', 'Chapultepec', 'Culiacán', 'Sinaloa', '80060', 24.7921500, -107.3850100, NULL, '667-300-3333', '6673003333', NULL, NULL, NULL, NULL, 'Lun-Dom 13:00-22:00', 40, 49.00, 200.00, 1, 40, 4.7, 3, 1, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:39:00'),
(4, 'Tacos El Güero', 'Tacos auténticos con receta familiar de más de 30 años. Tortillas hechas a mano cada mañana, carnes marinadas toda la noche. Un clásico de Culiacán que no puedes perderte.', 4, 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2e/0f/b1/85/caption.jpg?w=900&h=500&s=1', 'Mercado Garmendia Local 45', 'Centro', 'Culiacán', 'Sinaloa', '80000', 24.8060000, -107.3960000, NULL, '667-400-4444', '6674004444', NULL, NULL, NULL, NULL, 'Lun-Sáb 08:00-18:00', 20, 19.00, 80.00, 0, NULL, 5.0, 2, 1, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:35:32'),
(5, 'Green Bowl', 'Alimentación saludable y deliciosa. Ensaladas, bowls de proteína, wraps y smoothies preparados con ingredientes orgánicos de productores locales. Cuida tu salud sin sacrificar el sabor.', 5, 'https://saladbowl.mx/sucursal.JPG', 'Plaza Fórum Local B-12', 'Las Quintas', 'Culiacán', 'Sinaloa', '80060', 24.7880000, -107.3920000, NULL, '667-500-5555', '6675005555', NULL, NULL, NULL, NULL, 'Lun-Sáb 09:00-21:00', 15, 35.00, 120.00, 0, NULL, 0.0, 0, 0, 0, 1, '2026-06-03 03:31:09', '2026-06-04 02:42:34'),
(6, 'Smash Burgers MX', 'Smash burgers estilo americano con un toque mexicano inconfundible. Doble aplastada, queso fundido en el momento, salsas secretas de la casa. Descubre por qué somos los favoritos de la noche.', 1, 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/8f/f7/93/outside.jpg?w=900&h=500&s=1', 'Av. Universitaria 2201', 'Universidad', 'Culiacán', 'Sinaloa', '80010', 24.7945000, -107.4010000, NULL, '667-600-6666', '6676006666', NULL, NULL, NULL, NULL, 'Lun-Dom 13:00-00:00', 30, 29.00, 150.00, 1, 35, 4.0, 1, 1, 0, 1, '2026-06-03 03:31:09', '2026-06-04 02:39:49'),
(7, 'Ramen Kuroi', 'Ramen artesanal con caldo de 12 horas de cocción lenta. Recetas tradicionales japonesas adaptadas con ingredientes frescos del pacífico mexicano. Cada tazón es una obra de arte gastronómica.', 7, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS54FthWH-fKgbR-FCdqDSR4fGgjfEGAuxoUg&s', 'Calle Rosales 550', 'Centro', 'Culiacán', 'Sinaloa', '80000', 24.8030000, -107.3900000, NULL, '667-700-7777', '6677007777', NULL, NULL, NULL, NULL, 'Mar-Dom 13:00-22:00', 35, 39.00, 150.00, 1, 30, 4.0, 1, 0, 0, 1, '2026-06-03 03:31:09', '2026-06-04 02:45:57'),
(8, 'El Camarón Loco', 'Mariscos frescos del día, traídos directamente de Mazatlán cada mañana. Aguachiles, ceviches, cocteles y tostadas preparados en el momento. El mejor marisco del pacífico en tu mesa.', 8, 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/08/48/05/para-tu-comodidad-dos.jpg?w=800&h=-1&s=1', 'Blvd. Rolando Arjona 1100', 'Bonanza', 'Culiacán', 'Sinaloa', '80030', 24.8100000, -107.3800000, NULL, '667-800-8888', '6678008888', NULL, NULL, NULL, NULL, 'Lun-Dom 10:00-20:00', 30, 45.00, 200.00, 1, 50, 5.0, 2, 1, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:36:15');


-- ── Horarios detallados por día ─────────────────────────────────────────
CREATE TABLE horarios_restaurante (
  id             INT      UNSIGNED NOT NULL AUTO_INCREMENT,
  restaurante_id INT      UNSIGNED NOT NULL,
  dia_semana     TINYINT  NOT NULL           COMMENT '0=Lun 1=Mar ... 6=Dom',
  hora_apertura  TIME     DEFAULT NULL,
  hora_cierre    TIME     DEFAULT NULL,
  cerrado        TINYINT(1) DEFAULT 0,

  PRIMARY KEY (id),
  UNIQUE KEY uq_dia (restaurante_id, dia_semana),
  CONSTRAINT fk_horario_rest
    FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Horario detallado por día de la semana';


-- ── Imágenes adicionales del restaurante ───────────────────────────────
CREATE TABLE restaurante_imagenes (
  id             INT          UNSIGNED NOT NULL AUTO_INCREMENT,
  restaurante_id INT          UNSIGNED NOT NULL,
  url            VARCHAR(255) NOT NULL,
  descripcion    VARCHAR(100) DEFAULT NULL,
  orden          TINYINT      DEFAULT 0,
  created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_rest (restaurante_id),
  CONSTRAINT fk_img_rest
    FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Galería de imágenes del restaurante';


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 4 — MENÚ / PLATILLOS
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE categorias_menu (
  id             INT         UNSIGNED NOT NULL AUTO_INCREMENT,
  restaurante_id INT         UNSIGNED NOT NULL,
  nombre         VARCHAR(80) NOT NULL            COMMENT 'Ej: Entradas, Platos fuertes',
  orden          TINYINT     DEFAULT 0,

  PRIMARY KEY (id),
  INDEX idx_rest (restaurante_id),
  CONSTRAINT fk_catmenu_rest
    FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Secciones del menú por restaurante';


CREATE TABLE platillos (
  id               INT           UNSIGNED NOT NULL AUTO_INCREMENT,
  restaurante_id   INT           UNSIGNED NOT NULL,
  categoria_menu_id INT          UNSIGNED DEFAULT NULL,
  nombre           VARCHAR(120)  NOT NULL,
  descripcion      TEXT          DEFAULT NULL,
  precio           DECIMAL(8,2)  NOT NULL,
  precio_oferta    DECIMAL(8,2)  DEFAULT NULL     COMMENT 'Precio con descuento opcional',
  imagen           VARCHAR(255)  DEFAULT NULL,
  calorias         SMALLINT      DEFAULT NULL,
  es_vegetariano   TINYINT(1)    DEFAULT 0,
  es_vegano        TINYINT(1)    DEFAULT 0,
  es_picante       TINYINT(1)    DEFAULT 0,
  disponible       TINYINT(1)    DEFAULT 1,
  created_at       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_rest        (restaurante_id),
  INDEX idx_cat_menu    (categoria_menu_id),
  INDEX idx_disponible  (disponible),
  CONSTRAINT fk_platillo_rest
    FOREIGN KEY (restaurante_id)    REFERENCES restaurantes(id)    ON DELETE CASCADE,
  CONSTRAINT fk_platillo_catmenu
    FOREIGN KEY (categoria_menu_id) REFERENCES categorias_menu(id) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Platillos del menú de cada restaurante';


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 5 — RESEÑAS Y CALIFICACIONES
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE resenas (
  id             INT       UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id     INT       UNSIGNED NOT NULL,
  restaurante_id INT       UNSIGNED NOT NULL,
  -- Calificaciones por dimensión
  calificacion        TINYINT NOT NULL         COMMENT 'Calificación general 1-5',
  cal_comida          TINYINT DEFAULT NULL     COMMENT 'Calidad de la comida 1-5',
  cal_servicio        TINYINT DEFAULT NULL     COMMENT 'Calidad del servicio 1-5',
  cal_ambiente        TINYINT DEFAULT NULL     COMMENT 'Ambiente del lugar 1-5',
  cal_precio          TINYINT DEFAULT NULL     COMMENT 'Relación precio-calidad 1-5',
  -- Reseña
  titulo         VARCHAR(120) DEFAULT NULL,
  comentario     TEXT         DEFAULT NULL,
  -- Votos de utilidad
  votos_util     INT       DEFAULT 0           COMMENT 'Cuántos usuarios marcaron útil',
  -- Moderación
  visible        TINYINT(1)   DEFAULT 1,
  created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  -- Un usuario solo puede reseñar una vez por restaurante
  UNIQUE KEY uq_resena          (usuario_id, restaurante_id),
  INDEX idx_restaurante_id      (restaurante_id),
  INDEX idx_calificacion        (calificacion),

  CONSTRAINT chk_cal_general  CHECK (calificacion  BETWEEN 1 AND 5),
  CONSTRAINT chk_cal_comida   CHECK (cal_comida    IS NULL OR cal_comida   BETWEEN 1 AND 5),
  CONSTRAINT chk_cal_servicio CHECK (cal_servicio  IS NULL OR cal_servicio BETWEEN 1 AND 5),
  CONSTRAINT chk_cal_ambiente CHECK (cal_ambiente  IS NULL OR cal_ambiente BETWEEN 1 AND 5),
  CONSTRAINT chk_cal_precio   CHECK (cal_precio    IS NULL OR cal_precio   BETWEEN 1 AND 5),

  CONSTRAINT fk_resena_usuario
    FOREIGN KEY (usuario_id)     REFERENCES usuarios(id)     ON DELETE CASCADE,
  CONSTRAINT fk_resena_restaurante
    FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Reseñas y calificaciones de usuarios a restaurantes';


-- ── Votos de utilidad en reseñas ────────────────────────────────────────
CREATE TABLE resena_votos (
  id         INT      UNSIGNED NOT NULL AUTO_INCREMENT,
  resena_id  INT      UNSIGNED NOT NULL,
  usuario_id INT      UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_voto (resena_id, usuario_id),
  CONSTRAINT fk_voto_resena
    FOREIGN KEY (resena_id)  REFERENCES resenas(id)   ON DELETE CASCADE,
  CONSTRAINT fk_voto_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)  ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Votos de utilidad en reseñas';


-- ── Respuestas del restaurante a reseñas ────────────────────────────────
CREATE TABLE resena_respuestas (
  id             INT      UNSIGNED NOT NULL AUTO_INCREMENT,
  resena_id      INT      UNSIGNED NOT NULL,
  restaurante_id INT      UNSIGNED NOT NULL,
  respuesta      TEXT     NOT NULL,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_respuesta (resena_id),        -- Solo una respuesta por reseña
  CONSTRAINT fk_resp_resena
    FOREIGN KEY (resena_id)      REFERENCES resenas(id)      ON DELETE CASCADE,
  CONSTRAINT fk_resp_restaurante
    FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Respuestas oficiales del restaurante a reseñas';


-- ═══════════════════════════════════════════════════════════════════════════
--  TRIGGERS — Actualizar calificación promedio en restaurantes
-- ═══════════════════════════════════════════════════════════════════════════

DELIMITER $$

CREATE TRIGGER trg_resena_after_insert
AFTER INSERT ON resenas
FOR EACH ROW
BEGIN
  UPDATE restaurantes
  SET calificacion  = (
        SELECT ROUND(AVG(calificacion), 1)
        FROM resenas
        WHERE restaurante_id = NEW.restaurante_id AND visible = 1
      ),
      total_resenas = (
        SELECT COUNT(*) FROM resenas
        WHERE restaurante_id = NEW.restaurante_id AND visible = 1
      )
  WHERE id = NEW.restaurante_id;
END$$

CREATE TRIGGER trg_resena_after_update
AFTER UPDATE ON resenas
FOR EACH ROW
BEGIN
  UPDATE restaurantes
  SET calificacion  = (
        SELECT ROUND(AVG(calificacion), 1)
        FROM resenas
        WHERE restaurante_id = NEW.restaurante_id AND visible = 1
      ),
      total_resenas = (
        SELECT COUNT(*) FROM resenas
        WHERE restaurante_id = NEW.restaurante_id AND visible = 1
      )
  WHERE id = NEW.restaurante_id;
END$$

CREATE TRIGGER trg_resena_after_delete
AFTER DELETE ON resenas
FOR EACH ROW
BEGIN
  UPDATE restaurantes
  SET calificacion  = COALESCE((
        SELECT ROUND(AVG(calificacion), 1)
        FROM resenas
        WHERE restaurante_id = OLD.restaurante_id AND visible = 1
      ), 0.0),
      total_resenas = (
        SELECT COUNT(*) FROM resenas
        WHERE restaurante_id = OLD.restaurante_id AND visible = 1
      )
  WHERE id = OLD.restaurante_id;
END$$

-- Trigger: actualizar contador de votos útiles en reseña
CREATE TRIGGER trg_voto_after_insert
AFTER INSERT ON resena_votos
FOR EACH ROW
BEGIN
  UPDATE resenas SET votos_util = votos_util + 1 WHERE id = NEW.resena_id;
END$$

CREATE TRIGGER trg_voto_after_delete
AFTER DELETE ON resena_votos
FOR EACH ROW
BEGIN
  UPDATE resenas SET votos_util = GREATEST(votos_util - 1, 0) WHERE id = OLD.resena_id;
END$$

DELIMITER ;


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 6 — FAVORITOS
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE favoritos (
  id             INT      UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id     INT      UNSIGNED NOT NULL,
  restaurante_id INT      UNSIGNED NOT NULL,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_favorito     (usuario_id, restaurante_id),
  INDEX idx_fav_usuario      (usuario_id),
  INDEX idx_fav_restaurante  (restaurante_id),

  CONSTRAINT fk_fav_usuario
    FOREIGN KEY (usuario_id)     REFERENCES usuarios(id)     ON DELETE CASCADE,
  CONSTRAINT fk_fav_restaurante
    FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Restaurantes marcados como favoritos por el usuario';


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 7 — RESERVACIONES
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE reservaciones (
  id               INT          UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id       INT          UNSIGNED NOT NULL,
  restaurante_id   INT          UNSIGNED NOT NULL,
  -- Datos de la reserva
  fecha            DATE         NOT NULL,
  hora             TIME         NOT NULL,
  personas         TINYINT      NOT NULL DEFAULT 2,
  nombre_reserva   VARCHAR(120) NOT NULL           COMMENT 'Nombre de quien reserva',
  telefono         VARCHAR(20)  DEFAULT NULL,
  email_contacto   VARCHAR(150) DEFAULT NULL,
  -- Preferencias
  seccion          ENUM('interior','terraza','barra','sin_preferencia') DEFAULT 'sin_preferencia',
  ocasion          VARCHAR(80)  DEFAULT NULL        COMMENT 'Ej: cumpleaños, aniversario',
  notas            TEXT         DEFAULT NULL        COMMENT 'Solicitudes especiales',
  -- Estado
  estado           ENUM('pendiente','confirmada','cancelada','completada','no_show')
                   DEFAULT 'pendiente',
  codigo           VARCHAR(12)  DEFAULT NULL        COMMENT 'Código único de confirmación',
  motivo_cancel    VARCHAR(255) DEFAULT NULL,
  confirmada_at    DATETIME     NULL,
  cancelada_at     DATETIME     NULL,
  created_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_codigo          (codigo),
  INDEX idx_reserva_usuario     (usuario_id),
  INDEX idx_reserva_restaurante (restaurante_id),
  INDEX idx_reserva_fecha       (fecha),
  INDEX idx_reserva_estado      (estado),

  CONSTRAINT fk_reserva_usuario
    FOREIGN KEY (usuario_id)     REFERENCES usuarios(id)     ON DELETE CASCADE,
  CONSTRAINT fk_reserva_restaurante
    FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Reservaciones de mesa en restaurantes';


-- Trigger: generar código único al crear reservación
DELIMITER $$
CREATE TRIGGER trg_reserva_codigo
BEFORE INSERT ON reservaciones
FOR EACH ROW
BEGIN
  SET NEW.codigo = UPPER(CONCAT(
    SUBSTRING(MD5(RAND()), 1, 4), '-',
    SUBSTRING(MD5(RAND()), 1, 4)
  ));
END$$
DELIMITER ;


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 8 — PEDIDOS
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE pedidos (
  id               INT          UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id       INT          UNSIGNED NOT NULL,
  restaurante_id   INT          UNSIGNED NOT NULL,
  -- Entrega
  tipo_entrega     ENUM('domicilio','recoger') DEFAULT 'domicilio',
  direccion        VARCHAR(255) DEFAULT NULL,
  colonia_entrega  VARCHAR(100) DEFAULT NULL,
  referencia       VARCHAR(200) DEFAULT NULL,
  notas            TEXT         DEFAULT NULL,
  -- Importes
  subtotal         DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  costo_envio      DECIMAL(6,2)  NOT NULL DEFAULT 0.00,
  descuento        DECIMAL(8,2)  NOT NULL DEFAULT 0.00,
  total            DECIMAL(10,2) NOT NULL,
  -- Pago
  metodo_pago      ENUM('efectivo','tarjeta','transferencia') DEFAULT 'efectivo',
  pagado           TINYINT(1)    DEFAULT 0,
  -- Estado
  estado           ENUM('pendiente','confirmado','preparando','en_camino','entregado','cancelado')
                   DEFAULT 'pendiente',
  motivo_cancel    VARCHAR(255)  DEFAULT NULL,
  tiempo_estimado  SMALLINT      DEFAULT NULL     COMMENT 'Minutos estimados desde confirmación',
  created_at       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_pedido_usuario      (usuario_id),
  INDEX idx_pedido_restaurante  (restaurante_id),
  INDEX idx_pedido_estado       (estado),
  INDEX idx_pedido_fecha        (created_at),

  CONSTRAINT fk_pedido_usuario
    FOREIGN KEY (usuario_id)     REFERENCES usuarios(id),
  CONSTRAINT fk_pedido_restaurante
    FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id)
) ENGINE=InnoDB COMMENT='Pedidos realizados por usuarios';


CREATE TABLE pedido_detalle (
  id          INT          UNSIGNED NOT NULL AUTO_INCREMENT,
  pedido_id   INT          UNSIGNED NOT NULL,
  platillo_id INT          UNSIGNED NOT NULL,
  cantidad    TINYINT      NOT NULL DEFAULT 1,
  precio_unit DECIMAL(8,2) NOT NULL,
  notas       VARCHAR(200) DEFAULT NULL          COMMENT 'Ej: sin cebolla',
  subtotal    DECIMAL(10,2)
              GENERATED ALWAYS AS (cantidad * precio_unit) STORED,

  PRIMARY KEY (id),
  INDEX idx_det_pedido   (pedido_id),
  INDEX idx_det_platillo (platillo_id),

  CONSTRAINT fk_det_pedido
    FOREIGN KEY (pedido_id)   REFERENCES pedidos(id)   ON DELETE CASCADE,
  CONSTRAINT fk_det_platillo
    FOREIGN KEY (platillo_id) REFERENCES platillos(id)
) ENGINE=InnoDB COMMENT='Detalle de cada pedido (platillos y cantidades)';


-- ── Historial de estados del pedido ─────────────────────────────────────
CREATE TABLE pedido_historial (
  id         INT     UNSIGNED NOT NULL AUTO_INCREMENT,
  pedido_id  INT     UNSIGNED NOT NULL,
  estado     ENUM('pendiente','confirmado','preparando','en_camino','entregado','cancelado') NOT NULL,
  nota       VARCHAR(200) DEFAULT NULL,
  created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_hist_pedido (pedido_id),
  CONSTRAINT fk_hist_pedido
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Historial de cambios de estado del pedido';


-- Trigger: registrar cambio de estado automáticamente
DELIMITER $$
CREATE TRIGGER trg_pedido_estado
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
  IF OLD.estado <> NEW.estado THEN
    INSERT INTO pedido_historial (pedido_id, estado)
    VALUES (NEW.id, NEW.estado);
  END IF;
END$$
DELIMITER ;


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 9 — DIRECCIONES GUARDADAS DEL USUARIO
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE usuario_direcciones (
  id          INT          UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id  INT          UNSIGNED NOT NULL,
  etiqueta    VARCHAR(50)  NOT NULL            COMMENT 'Casa, Trabajo, etc.',
  direccion   VARCHAR(255) NOT NULL,
  colonia     VARCHAR(100) DEFAULT NULL,
  ciudad      VARCHAR(80)  DEFAULT NULL,
  cp          VARCHAR(10)  DEFAULT NULL,
  referencia  VARCHAR(200) DEFAULT NULL,
  latitud     DECIMAL(10,7) DEFAULT NULL,
  longitud    DECIMAL(10,7) DEFAULT NULL,
  predeterminada TINYINT(1) DEFAULT 0,
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_dir_usuario (usuario_id),
  CONSTRAINT fk_dir_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Direcciones de entrega guardadas del usuario';


-- ═══════════════════════════════════════════════════════════════════════════
--  BLOQUE 10 — NOTIFICACIONES
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE notificaciones (
  id         INT          UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id INT          UNSIGNED NOT NULL,
  tipo       ENUM('pedido','reservacion','resena','promo','sistema') NOT NULL,
  titulo     VARCHAR(120) NOT NULL,
  mensaje    TEXT         NOT NULL,
  leida      TINYINT(1)   DEFAULT 0,
  url        VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_noti_usuario (usuario_id),
  INDEX idx_noti_leida   (leida),
  CONSTRAINT fk_noti_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Notificaciones del sistema al usuario';


-- ═══════════════════════════════════════════════════════════════════════════
--  VISTAS ÚTILES
-- ═══════════════════════════════════════════════════════════════════════════

-- Vista: restaurantes con info completa
CREATE VIEW v_restaurantes AS
SELECT
  r.*,
  c.nombre        AS categoria_nombre,
  c.icono         AS categoria_icono,
  (SELECT COUNT(*) FROM favoritos f WHERE f.restaurante_id = r.id) AS total_favoritos,
  (SELECT COUNT(*) FROM pedidos   p WHERE p.restaurante_id = r.id
     AND p.estado NOT IN ('cancelado'))                             AS total_pedidos
FROM restaurantes r
LEFT JOIN categorias c ON r.categoria_id = c.id
WHERE r.activo = 1;


-- Vista: reseñas con datos del autor
CREATE VIEW v_resenas AS
SELECT
  re.*,
  u.nombre   AS autor_nombre,
  u.username AS autor_username,
  u.avatar   AS autor_avatar,
  r.nombre   AS restaurante_nombre
FROM resenas re
JOIN usuarios     u ON re.usuario_id     = u.id
JOIN restaurantes r ON re.restaurante_id = r.id
WHERE re.visible = 1;


-- Vista: perfil de usuario con contadores
CREATE VIEW v_perfil_usuario AS
SELECT
  u.id, u.nombre, u.username, u.email, u.telefono, u.avatar, u.rol, u.created_at,
  (SELECT COUNT(*) FROM favoritos    f WHERE f.usuario_id = u.id)  AS total_favoritos,
  (SELECT COUNT(*) FROM resenas      r WHERE r.usuario_id = u.id)  AS total_resenas,
  (SELECT COUNT(*) FROM reservaciones rv WHERE rv.usuario_id = u.id) AS total_reservaciones,
  (SELECT COUNT(*) FROM pedidos      p WHERE p.usuario_id = u.id
     AND p.estado = 'entregado')                                    AS total_pedidos_completados
FROM usuarios u
WHERE u.activo = 1;


-- Vista: reservaciones con info completa
CREATE VIEW v_reservaciones AS
SELECT
  rv.*,
  u.nombre   AS usuario_nombre,
  u.email    AS usuario_email,
  r.nombre   AS restaurante_nombre,
  r.direccion AS restaurante_direccion,
  r.telefono AS restaurante_telefono
FROM reservaciones rv
JOIN usuarios     u ON rv.usuario_id     = u.id
JOIN restaurantes r ON rv.restaurante_id = r.id;


-- Vista: pedidos con totales y estado
CREATE VIEW v_pedidos AS
SELECT
  p.*,
  u.nombre   AS usuario_nombre,
  u.email    AS usuario_email,
  r.nombre   AS restaurante_nombre,
  (SELECT COUNT(*) FROM pedido_detalle pd WHERE pd.pedido_id = p.id) AS total_items
FROM pedidos p
JOIN usuarios     u ON p.usuario_id     = u.id
JOIN restaurantes r ON p.restaurante_id = r.id;


-- ═══════════════════════════════════════════════════════════════════════════
--  DATOS DE EJEMPLO
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Categorías ──────────────────────────────────────────────────────────
INSERT INTO categorias (nombre, icono, descripcion) VALUES
  ('Hamburguesas', '🍔', 'Burgers artesanales y clásicas'),
  ('Pizza',        '🍕', 'Pizza italiana y artesanal'),
  ('Sushi',        '🍱', 'Sushi y cocina japonesa'),
  ('Tacos',        '🌮', 'Tacos mexicanos auténticos'),
  ('Ensaladas',    '🥗', 'Opciones saludables y frescas'),
  ('Postres',      '🍰', 'Pasteles, helados y dulces'),
  ('Ramen',        '🍜', 'Ramen y fideos asiáticos'),
  ('Mariscos',     '🦞', 'Mariscos frescos del pacífico');


-- ── Restaurantes ────────────────────────────────────────────────────────



-- ── Horarios detallados ──────────────────────────────────────────────────
INSERT INTO horarios_restaurante (restaurante_id, dia_semana, hora_apertura, hora_cierre, cerrado) VALUES
  -- Burger Bros (abre todos los días)
  (1,0,'12:00','23:00',0),(1,1,'12:00','23:00',0),(1,2,'12:00','23:00',0),
  (1,3,'12:00','23:00',0),(1,4,'12:00','23:00',0),(1,5,'12:00','00:00',0),(1,6,'12:00','00:00',0),
  -- Pizza Mia (cierra lunes)
  (2,0,NULL,NULL,1),(2,1,'13:00','23:00',0),(2,2,'13:00','23:00',0),
  (2,3,'13:00','23:00',0),(2,4,'13:00','23:00',0),(2,5,'13:00','23:30',0),(2,6,'13:00','23:30',0),
  -- Tacos El Güero (cierra domingo)
  (4,0,'08:00','18:00',0),(4,1,'08:00','18:00',0),(4,2,'08:00','18:00',0),
  (4,3,'08:00','18:00',0),(4,4,'08:00','18:00',0),(4,5,'08:00','18:00',0),(4,6,NULL,NULL,1);


-- ── Categorías de menú ──────────────────────────────────────────────────
INSERT INTO categorias_menu (restaurante_id, nombre, orden) VALUES
  (1,'Burgers clásicas',1),(1,'Burgers especiales',2),(1,'Acompañamientos',3),(1,'Bebidas',4),
  (2,'Pizzas rojas',1),(2,'Pizzas blancas',2),(2,'Entradas',3),(2,'Postres',4),
  (3,'Rolls especiales',1),(3,'Nigiri y sashimi',2),(3,'Entradas japonesas',3),
  (4,'Tacos de carne',1),(4,'Tacos del mar',2),(4,'Extras',3),
  (6,'Smash burgers',1),(6,'Pollo',2),(6,'Acompañamientos',3),
  (7,'Ramen',1),(7,'Gyozas y entradas',2),
  (8,'Crudos',1),(8,'Cocinados',2),(8,'Bebidas del mar',3);


-- ── Platillos ───────────────────────────────────────────────────────────
INSERT INTO platillos (restaurante_id, categoria_menu_id, nombre, descripcion, precio, es_vegetariano, es_picante) VALUES
  -- Burger Bros
  (1,1,'Classic Smash',       'Doble carne angus, queso americano, lechuga, tomate, cebolla, pepinillos, mayo',     129.00, 0, 0),
  (1,1,'BBQ Bacon',           'Carne angus, tocino crujiente, salsa BBQ casera, queso cheddar, aros de cebolla',    149.00, 0, 0),
  (1,1,'Mushroom Swiss',      'Champiñones salteados con mantequilla, queso suizo, cebolla caramelizada',           139.00, 0, 0),
  (1,2,'Spicy Jalapeño',      'Doble carne, queso pepper jack, jalapeños frescos y encurtidos, salsa habanero',     149.00, 0, 1),
  (1,2,'Truffle Smash',       'Carne angus, queso brie, cebolla caramelizada, mayonesa de trufa',                   169.00, 0, 0),
  (1,3,'Papas fritas',        'Papas corte natural con sal de mar',                                                  49.00, 1, 0),
  (1,3,'Aros de cebolla',     'Aros crujientes con dip de chipotle',                                                 59.00, 1, 0),

  -- Pizza Mia
  (2,5,'Margherita',          'Salsa de tomate San Marzano, mozzarella de búfala, albahaca fresca, aceite de oliva',159.00, 1, 0),
  (2,5,'Pepperoni',           'Pepperoni importado, mozzarella doble, salsa de tomate, orégano',                    179.00, 0, 0),
  (2,5,'Quattro Stagioni',    'Jamón, champiñones, alcachofas, aceitunas, mozzarella, dividida en cuatro secciones',189.00, 0, 0),
  (2,6,'Bianca con Rúcula',   'Base de aceite, ricotta, mozzarella, rúcula fresca, parmesano y prosciutto',         199.00, 0, 0),
  (2,6,'4 Quesos',            'Mozzarella, gorgonzola, parmesano, ricotta sobre base de aceite de oliva',           189.00, 1, 0),

  -- Sakura Sushi
  (3,9,'Roll Sakura Especial','8 piezas: salmón, aguacate, cream cheese, tobiko, salsa especial de la casa',        189.00, 0, 0),
  (3,9,'Dragon Roll',         '8 piezas: anguila tempura, pepino, aguacate, salsa de anguila y ajonjolí',           219.00, 0, 0),
  (3,9,'Spicy Tuna Roll',     '8 piezas: atún spicy, pepino, sriracha, cebollín',                                   179.00, 0, 1),
  (3,10,'Nigiri Mixto',       '10 piezas variadas: atún, salmón, camarón, pulpo, anguila',                          229.00, 0, 0),
  (3,10,'Sashimi Premium',    '15 cortes de sashimi de atún rojo y salmón noruego con daikon y jengibre',           279.00, 0, 0),

  -- Tacos El Güero
  (4,12,'Taco de Birria',     'Birria de res, consomé para remojar, cebolla, cilantro, limón, tortilla maíz',        45.00, 0, 0),
  (4,12,'Taco de Suadero',    'Suadero a la plancha, tortilla de maíz artesanal, salsa verde',                       40.00, 0, 0),
  (4,12,'Taco de Carnitas',   'Carnitas de cerdo con manteca, cebolla, cilantro, salsa roja',                        45.00, 0, 0),
  (4,13,'Taco Gobernador',    'Camarón salteado, queso fundido, chile güero, tortilla de harina tostada',            65.00, 0, 1),
  (4,13,'Taco de Marlín',     'Marlín ahumado, jitomate, cebolla, chile serrano, tortilla de maíz',                  55.00, 0, 1),

  -- Smash Burgers MX
  (6,15,'Smash Doble MX',     'Doble carne aplastada, queso americano x2, jalapeños, guacamole, salsa especial',    159.00, 0, 1),
  (6,15,'Smash Sencilla',     'Carne aplastada, queso americano, pepinillos, cebolla, mostaza, ketchup',             129.00, 0, 0),
  (6,16,'Crispy Chicken',     'Pollo crujiente al estilo Nashville, coleslaw, jalapeños encurtidos, mayo sriracha',  149.00, 0, 1),

  -- Ramen Kuroi
  (7,18,'Ramen Tonkotsu',     'Caldo de hueso de cerdo 12h, chashu, huevo marinado, nori, maíz, cebollín',          169.00, 0, 0),
  (7,18,'Ramen Miso',         'Base de miso rojo, tofu sedoso, champiñones shiitake, espinacas, cebollín',          155.00, 1, 0),
  (7,18,'Ramen Spicy Karaage','Caldo spicy, pollo karaage crujiente, kimchi, huevo, bambú',                         175.00, 0, 1),
  (7,19,'Gyozas de Cerdo',    '6 piezas de gyoza rellenas de cerdo y verduras con salsa ponzu',                      79.00, 0, 0),

  -- El Camarón Loco
  (8,21,'Aguachile Verde',    'Camarón fresco, pepino, cebolla morada, chile verde, jugo de limón, tostadas',       149.00, 0, 1),
  (8,21,'Aguachile Negro',    'Camarón en salsa de chile negro, soya, ajo, jengibre, pepino, cebolla morada',        159.00, 0, 1),
  (8,21,'Ceviche Sinaloa',    'Camarón cocido, jitomate, pepino, cilantro, cebolla, jugo de limón, tostadas',       139.00, 0, 0),
  (8,22,'Camarón a la Diabla','Camarón en salsa de chiles rojos asados, ajo, mantequilla, arroz y ensalada',        169.00, 0, 1);


-- ── Usuarios ────────────────────────────────────────────────────────────
-- Todos tienen password: Admin123!
-- Hash bcrypt rounds=12 de "Admin123!"
INSERT INTO usuarios (nombre, username, email, password, telefono, rol) VALUES
  ('Admin FoodGo',  'admin',   'admin@foodgo.com',   '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewqEMhJqnJiZT5.G', '6671000000', 'admin'),
  ('Juan Pérez',    'juanp',   'juan@ejemplo.com',   '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewqEMhJqnJiZT5.G', '6672000000', 'cliente'),
  ('María López',   'marial',  'maria@ejemplo.com',  '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewqEMhJqnJiZT5.G', '6673000000', 'cliente'),
  ('Carlos Ruiz',   'carlosr', 'carlos@ejemplo.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewqEMhJqnJiZT5.G', '6674000000', 'cliente'),
  ('Ana Gutiérrez', 'anag',    'ana@ejemplo.com',    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewqEMhJqnJiZT5.G', '6675000000', 'cliente');


-- ── Direcciones de usuarios ──────────────────────────────────────────────
INSERT INTO usuario_direcciones (usuario_id, etiqueta, direccion, colonia, ciudad, cp, referencia, predeterminada) VALUES
  (2, 'Casa',     'Calle Cedros 412',         'Guadalupe',   'Culiacán', '80220', 'Casa blanca con portón negro',   1),
  (2, 'Trabajo',  'Blvd. Insurgentes 980',    'Los Pinos',   'Culiacán', '80020', 'Edificio corporativo piso 3',    0),
  (3, 'Casa',     'Av. de los Olivos 88',     'Chapultepec', 'Culiacán', '80060', 'Fraccionamiento puerta 4',       1),
  (4, 'Casa',     'Calle Morelos 230 Int. 5', 'Centro',      'Culiacán', '80000', 'Edificio beige, departamento 5', 1);


-- ── Reseñas ─────────────────────────────────────────────────────────────
-- (Los triggers actualizan automáticamente calificacion y total_resenas)
INSERT INTO resenas (usuario_id, restaurante_id, calificacion, cal_comida, cal_servicio, cal_ambiente, cal_precio, titulo, comentario) VALUES
  (2, 1, 5, 5, 5, 4, 5, 'La mejor burger de Culiacán',
   'Increíble la calidad de la carne, muy jugosa y el pan artesanal es diferente a cualquier otro lugar. El servicio fue rápido y atento. Totalmente recomendado.'),

  (3, 1, 4, 5, 4, 3, 4, 'Muy rica, solo tardó un poco',
   'Las burgers están excelentes, la carne angus se nota la diferencia. El servicio tardó un poco pero la espera vale la pena. Volveré pronto.'),

  (4, 1, 5, 5, 5, 5, 4, 'Experiencia perfecta',
   'Todo estuvo increíble: la comida, el servicio y el ambiente. La truffle smash es para morirse de rica.'),

  (2, 3, 5, 5, 5, 5, 4, 'Sushi de nivel internacional',
   'El pescado es fresquísimo, se nota que es de importación. El Dragon Roll es espectacular. Los chefs claramente saben lo que hacen.'),

  (3, 3, 5, 5, 4, 5, 3, 'Increíble pero caro',
   'La calidad es inigualable en Culiacán, el sashimi premium es puro sabor a mar. Un poco caro pero para una ocasión especial totalmente vale.'),

  (5, 3, 4, 4, 5, 5, 4, 'Muy buena experiencia',
   'El lugar se ve muy limpio y elegante. El servicio fue excelente, muy atentos. Los rolls especiales están deliciosos.'),

  (2, 4, 5, 5, 5, 3, 5, 'Los tacos más ricos que he probado',
   'Los tacos de birria son de otro nivel. El consomé es espectacular y las tortillas hechas a mano marcan la diferencia. Llevan 30 años y se nota la experiencia.'),

  (4, 4, 5, 5, 4, 3, 5, 'Auténticos y deliciosos',
   'Los tacos gobernador son lo mejor que he comido. El marlín ahumado es único. Precios muy accesibles para la calidad que ofrecen.'),

  (3, 6, 4, 5, 4, 4, 4, 'Smash perfecta',
   'La técnica del smash hace una diferencia brutal en la textura de la carne. La salsa especial de la casa es adictiva. Muy buena opción nocturna.'),

  (2, 7, 4, 5, 3, 4, 3, 'Ramen de calidad, servicio mejorable',
   'El tonkotsu es delicioso, el caldo tiene mucho cuerpo y sabor. El huevo marinado perfecto. El servicio estuvo un poco lento pero la comida compensa.'),

  (5, 8, 5, 5, 5, 4, 4, 'El mejor aguachile de Culiacán',
   'El aguachile negro es una experiencia completa. El camarón fresquísimo, la salsa equilibrada con el picante justo. El camarón a la diabla también está brutal.'),

  (3, 8, 5, 5, 5, 5, 4, 'Mariscos fresquísimos',
   'Se nota inmediatamente que el marisco es del día. El ceviche sinaloa es clásico y perfecto. El lugar tiene muy buen ambiente para comer mariscos.'),

  (4, 2, 4, 5, 4, 4, 3, 'Pizza italiana auténtica',
   'La margherita es perfecta, la masa tiene ese sabor a masa madre que pocas pizzerías logran. El horno de leña marca la diferencia. Un poco cara pero vale.'),

  (5, 2, 5, 5, 5, 5, 4, 'La mejor pizza de la ciudad',
   'La Quattro Stagioni es increíble, cada sección perfectamente equilibrada. El ambiente es muy agradable y el servicio excelente. Ya es mi lugar favorito de pizza.');


-- ── Respuestas de restaurantes ──────────────────────────────────────────
INSERT INTO resena_respuestas (resena_id, restaurante_id, respuesta) VALUES
  (1, 1, '¡Muchas gracias por tu reseña! Nos alegra mucho que hayas disfrutado la experiencia. Trabajamos todos los días para mantenernos como la mejor burger de Culiacán. ¡Te esperamos pronto!'),
  (4, 3, 'Gracias por visitarnos y compartir tu experiencia. Nos esforzamos en traer los mejores ingredientes para ofrecerte sushi de calidad internacional. ¡Esperamos verte de nuevo pronto!'),
  (7, 4, '¡30 años de tradición y cada reseña como esta nos llena de orgullo! Gracias por reconocer el esfuerzo de nuestra familia. Las tortillas a mano son nuestro secreto. ¡Saludos!');


-- ── Favoritos ───────────────────────────────────────────────────────────
INSERT INTO favoritos (usuario_id, restaurante_id) VALUES
  (2,1),(2,3),(2,4),(2,8),
  (3,1),(3,2),(3,8),
  (4,3),(4,4),(4,6),
  (5,7),(5,8),(5,1);


-- ── Reservaciones ───────────────────────────────────────────────────────
INSERT INTO reservaciones
  (usuario_id, restaurante_id, fecha, hora, personas, nombre_reserva, telefono,
   email_contacto, seccion, ocasion, notas, estado)
VALUES
  (2, 1, DATE_ADD(CURDATE(), INTERVAL 3 DAY),  '20:00:00', 4,
   'Juan Pérez',    '6672000000', 'juan@ejemplo.com',
   'terraza', 'cumpleaños', 'Mesa en terraza si es posible, es cumpleaños de mi esposa', 'confirmada'),

  (3, 3, DATE_ADD(CURDATE(), INTERVAL 1 DAY),  '14:00:00', 2,
   'María López',   '6673000000', 'maria@ejemplo.com',
   'interior', 'aniversario', 'Aniversario de bodas, si es posible decoración discreta', 'pendiente'),

  (4, 6, DATE_ADD(CURDATE(), INTERVAL 5 DAY),  '21:00:00', 6,
   'Carlos Ruiz',   '6674000000', 'carlos@ejemplo.com',
   'sin_preferencia', NULL, 'Somos 6 personas, necesitamos mesa larga', 'pendiente'),

  (5, 2, DATE_ADD(CURDATE(), INTERVAL 7 DAY),  '19:30:00', 3,
   'Ana Gutiérrez', '6675000000', 'ana@ejemplo.com',
   'interior', NULL, NULL, 'confirmada'),

  -- Reservación pasada completada
  (2, 3, DATE_SUB(CURDATE(), INTERVAL 10 DAY), '20:00:00', 2,
   'Juan Pérez',    '6672000000', 'juan@ejemplo.com',
   'interior', NULL, NULL, 'completada');


-- ── Pedidos ─────────────────────────────────────────────────────────────
INSERT INTO pedidos
  (usuario_id, restaurante_id, tipo_entrega, direccion, colonia_entrega,
   subtotal, costo_envio, descuento, total, metodo_pago, pagado, estado, tiempo_estimado)
VALUES
  (2, 1, 'domicilio', 'Calle Cedros 412', 'Guadalupe',
   278.00, 29.00, 0.00, 307.00, 'tarjeta', 1, 'entregado', 30),

  (3, 3, 'domicilio', 'Av. de los Olivos 88', 'Chapultepec',
   408.00, 49.00, 0.00, 457.00, 'efectivo', 1, 'entregado', 45),

  (2, 4, 'domicilio', 'Calle Cedros 412', 'Guadalupe',
   170.00, 19.00, 0.00, 189.00, 'tarjeta', 1, 'entregado', 25),

  (4, 6, 'domicilio', 'Calle Morelos 230 Int. 5', 'Centro',
   308.00, 29.00, 0.00, 337.00, 'efectivo', 0, 'preparando', 35),

  (5, 8, 'domicilio', 'Blvd. Universitarios 1500', 'Universidad',
   308.00, 45.00, 0.00, 353.00, 'tarjeta', 1, 'en_camino', 30);


-- ── Detalle de pedidos ───────────────────────────────────────────────────
INSERT INTO pedido_detalle (pedido_id, platillo_id, cantidad, precio_unit, notas) VALUES
  -- Pedido 1: Burger Bros
  (1, 1, 1, 129.00, NULL),
  (1, 2, 1, 149.00, 'Sin pepinillos por favor'),

  -- Pedido 2: Sakura Sushi
  (2, 13, 1, 189.00, NULL),
  (2, 16, 1, 229.00, NULL),

  -- Pedido 3: Tacos El Güero
  (3, 18, 2, 45.00, NULL),
  (3, 20, 2, 40.00, NULL),

  -- Pedido 4: Smash Burgers MX
  (4, 23, 1, 159.00, 'Extra jalapeños'),
  (4, 24, 1, 129.00, NULL),

  -- Pedido 5: El Camarón Loco
  (5, 29, 1, 149.00, NULL),
  (5, 31, 1, 139.00, NULL);


-- ── Notificaciones ───────────────────────────────────────────────────────
INSERT INTO notificaciones (usuario_id, tipo, titulo, mensaje, url) VALUES
  (2, 'reservacion', '¡Reservación confirmada!',
   'Tu reservación en Burger Bros para el sábado a las 8:00 PM ha sido confirmada. Código: verificar en perfil.',
   '/perfil#reservaciones'),

  (3, 'reservacion', 'Reservación pendiente',
   'Tu reservación en Sakura Sushi está pendiente de confirmación. Te avisaremos pronto.',
   '/perfil#reservaciones'),

  (4, 'pedido', 'Tu pedido está en camino',
   'Tu pedido de Smash Burgers MX ya salió y llegará en aproximadamente 35 minutos.',
   '/perfil#pedidos'),

  (5, 'pedido', 'Pedido entregado',
   '¡Tu pedido de El Camarón Loco fue entregado! ¿Cómo estuvo? Déjanos una reseña.',
   '/restaurante/8#resenas'),

  (2, 'sistema', '¡Bienvenido a FoodGo!',
   'Gracias por registrarte. Descubre los mejores restaurantes de Culiacán y haz tu primer pedido.',
   '/');

SET FOREIGN_KEY_CHECKS = 1;

-- ═══════════════════════════════════════════════════════════════════════════
--  FIN DEL SCRIPT
--  Tablas creadas: 15
--  Vistas creadas: 5
--  Triggers creados: 8
--  Registros de ejemplo insertados en todas las tablas
-- ═══════════════════════════════════════════════════════════════════════════
