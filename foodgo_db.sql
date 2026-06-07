-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 04-06-2026 a las 06:32:45
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `foodgo_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `restaurantes`
--

CREATE TABLE `restaurantes` (
  `id` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(120) NOT NULL,
  `descripcion` text DEFAULT NULL COMMENT 'Descripción larga del restaurante',
  `categoria_id` int(10) UNSIGNED DEFAULT NULL,
  `imagen` varchar(255) DEFAULT NULL COMMENT 'Imagen principal',
  `direccion` varchar(255) DEFAULT NULL,
  `colonia` varchar(100) DEFAULT NULL,
  `ciudad` varchar(80) DEFAULT NULL,
  `estado_mx` varchar(80) DEFAULT NULL COMMENT 'Estado de la república',
  `cp` varchar(10) DEFAULT NULL COMMENT 'Código postal',
  `latitud` decimal(10,7) DEFAULT NULL COMMENT 'Para mapas',
  `longitud` decimal(10,7) DEFAULT NULL COMMENT 'Para mapas',
  `maps_url` varchar(500) DEFAULT NULL COMMENT 'Link directo a Google Maps',
  `telefono` varchar(20) DEFAULT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `sitio_web` varchar(255) DEFAULT NULL,
  `instagram` varchar(100) DEFAULT NULL,
  `facebook` varchar(100) DEFAULT NULL,
  `horario` varchar(150) DEFAULT NULL COMMENT 'Texto libre: Lun-Vie 12:00-23:00',
  `tiempo_entrega` smallint(6) DEFAULT 30 COMMENT 'Minutos estimados de entrega',
  `costo_envio` decimal(6,2) DEFAULT 0.00,
  `pedido_minimo` decimal(8,2) DEFAULT 0.00,
  `acepta_reservas` tinyint(1) DEFAULT 1,
  `capacidad` smallint(6) DEFAULT NULL COMMENT 'Personas máximo en reservas',
  `calificacion` decimal(3,1) DEFAULT 0.0,
  `total_resenas` int(11) DEFAULT 0,
  `tendencia` tinyint(1) DEFAULT 0,
  `verificado` tinyint(1) DEFAULT 0 COMMENT 'Restaurante verificado por FoodGo',
  `activo` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Restaurantes registrados en la plataforma';

--
-- Volcado de datos para la tabla `restaurantes`
--

INSERT INTO `restaurantes` (`id`, `nombre`, `descripcion`, `categoria_id`, `imagen`, `direccion`, `colonia`, `ciudad`, `estado_mx`, `cp`, `latitud`, `longitud`, `maps_url`, `telefono`, `whatsapp`, `email`, `sitio_web`, `instagram`, `facebook`, `horario`, `tiempo_entrega`, `costo_envio`, `pedido_minimo`, `acepta_reservas`, `capacidad`, `calificacion`, `total_resenas`, `tendencia`, `verificado`, `activo`, `created_at`, `updated_at`) VALUES
(1, 'Burger Bros', 'Las mejores hamburguesas artesanales de Culiacán. Carne angus 100% fresca, nunca congelada. Cada burger es armada a mano con ingredientes seleccionados y pan artesanal horneado diariamente.', 1, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQ3I4mEjGz1ojyEQGcHHGm85xXTtzcYTNzkQ&s', 'Blvd. Insurgentes 1420', 'Los Pinos', 'Culiacán', 'Sinaloa', '80020', 24.7996200, -107.3879300, NULL, '667-100-1111', '6671001111', NULL, NULL, NULL, NULL, 'Lun-Dom 12:00-23:00', 25, 29.00, 150.00, 1, 60, 4.7, 3, 1, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:37:44'),
(2, 'Pizza Mia', 'Pizza italiana auténtica horneada en horno de leña. Masa madre de fermentación lenta, ingredientes importados directamente de Italia. La tradición napolitana en Culiacán.', 2, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9V0BTDiG8qjj1WQLMLlrEiSRJCXxXu32hJA&s', 'Av. Álvaro Obregón 340', 'Centro', 'Culiacán', 'Sinaloa', '80000', 24.8050100, -107.3940200, NULL, '667-200-2222', '6672002222', NULL, NULL, NULL, NULL, 'Mar-Dom 13:00-23:00', 35, 0.00, 100.00, 1, 45, 4.5, 2, 0, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:43:41'),
(3, 'Sakura Sushi', 'Sushi premium elaborado por chefs con entrenamiento en Japón. Pescado fresco de importación directo del mercado Tsukiji. Experiencia gastronómica japonesa única en el noroeste de México.', 3, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQOrqWk5t_H_93VbgXpdxsuRhBeDSCZSNyleA&s', 'Calle Ángel Flores 890', 'Chapultepec', 'Culiacán', 'Sinaloa', '80060', 24.7921500, -107.3850100, NULL, '667-300-3333', '6673003333', NULL, NULL, NULL, NULL, 'Lun-Dom 13:00-22:00', 40, 49.00, 200.00, 1, 40, 4.7, 3, 1, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:39:00'),
(4, 'Tacos El Güero', 'Tacos auténticos con receta familiar de más de 30 años. Tortillas hechas a mano cada mañana, carnes marinadas toda la noche. Un clásico de Culiacán que no puedes perderte.', 4, 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2e/0f/b1/85/caption.jpg?w=900&h=500&s=1', 'Mercado Garmendia Local 45', 'Centro', 'Culiacán', 'Sinaloa', '80000', 24.8060000, -107.3960000, NULL, '667-400-4444', '6674004444', NULL, NULL, NULL, NULL, 'Lun-Sáb 08:00-18:00', 20, 19.00, 80.00, 0, NULL, 5.0, 2, 1, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:35:32'),
(5, 'Green Bowl', 'Alimentación saludable y deliciosa. Ensaladas, bowls de proteína, wraps y smoothies preparados con ingredientes orgánicos de productores locales. Cuida tu salud sin sacrificar el sabor.', 5, 'https://saladbowl.mx/sucursal.JPG', 'Plaza Fórum Local B-12', 'Las Quintas', 'Culiacán', 'Sinaloa', '80060', 24.7880000, -107.3920000, NULL, '667-500-5555', '6675005555', NULL, NULL, NULL, NULL, 'Lun-Sáb 09:00-21:00', 15, 35.00, 120.00, 0, NULL, 0.0, 0, 0, 0, 1, '2026-06-03 03:31:09', '2026-06-04 02:42:34'),
(6, 'Smash Burgers MX', 'Smash burgers estilo americano con un toque mexicano inconfundible. Doble aplastada, queso fundido en el momento, salsas secretas de la casa. Descubre por qué somos los favoritos de la noche.', 1, 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/8f/f7/93/outside.jpg?w=900&h=500&s=1', 'Av. Universitaria 2201', 'Universidad', 'Culiacán', 'Sinaloa', '80010', 24.7945000, -107.4010000, NULL, '667-600-6666', '6676006666', NULL, NULL, NULL, NULL, 'Lun-Dom 13:00-00:00', 30, 29.00, 150.00, 1, 35, 4.0, 1, 1, 0, 1, '2026-06-03 03:31:09', '2026-06-04 02:39:49'),
(7, 'Ramen Kuroi', 'Ramen artesanal con caldo de 12 horas de cocción lenta. Recetas tradicionales japonesas adaptadas con ingredientes frescos del pacífico mexicano. Cada tazón es una obra de arte gastronómica.', 7, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS54FthWH-fKgbR-FCdqDSR4fGgjfEGAuxoUg&s', 'Calle Rosales 550', 'Centro', 'Culiacán', 'Sinaloa', '80000', 24.8030000, -107.3900000, NULL, '667-700-7777', '6677007777', NULL, NULL, NULL, NULL, 'Mar-Dom 13:00-22:00', 35, 39.00, 150.00, 1, 30, 4.0, 1, 0, 0, 1, '2026-06-03 03:31:09', '2026-06-04 02:45:57'),
(8, 'El Camarón Loco', 'Mariscos frescos del día, traídos directamente de Mazatlán cada mañana. Aguachiles, ceviches, cocteles y tostadas preparados en el momento. El mejor marisco del pacífico en tu mesa.', 8, 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/08/48/05/para-tu-comodidad-dos.jpg?w=800&h=-1&s=1', 'Blvd. Rolando Arjona 1100', 'Bonanza', 'Culiacán', 'Sinaloa', '80030', 24.8100000, -107.3800000, NULL, '667-800-8888', '6678008888', NULL, NULL, NULL, NULL, 'Lun-Dom 10:00-20:00', 30, 45.00, 200.00, 1, 50, 5.0, 2, 1, 1, 1, '2026-06-03 03:31:09', '2026-06-04 02:36:15');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `restaurantes`
--
ALTER TABLE `restaurantes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_categoria` (`categoria_id`),
  ADD KEY `idx_ciudad` (`ciudad`),
  ADD KEY `idx_calificacion` (`calificacion`),
  ADD KEY `idx_tendencia` (`tendencia`),
  ADD KEY `idx_activo` (`activo`);
ALTER TABLE `restaurantes` ADD FULLTEXT KEY `idx_busqueda` (`nombre`,`descripcion`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `restaurantes`
--
ALTER TABLE `restaurantes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `restaurantes`
--
ALTER TABLE `restaurantes`
  ADD CONSTRAINT `fk_rest_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
