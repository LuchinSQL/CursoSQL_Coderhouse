-- Este script inserta datos de prueba en las tablas de la base de datos 'facturacion'.
-- Se asume que las tablas ya han sido creadas por 'creacion_objetos_bbdd.sql'.
-- Los datos se insertan en el orden correcto para respetar las claves foráneas:
-- Primero dimensiones, luego la tabla de hechos.

USE `facturacion`;

-- Desactivar temporalmente las verificaciones de claves foráneas para la inserción inicial
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- INSERCIÓN DE DATOS EN TABLAS DE DIMENSIÓN
-- (Valores únicos extraídos de tu data original y ampliados con ejemplos)
-- --------------------------------------------------------

-- Dimensión: `tbl_facturas_tipo`
INSERT IGNORE INTO `tbl_facturas_tipo` (`TipoDocum`, `DescDoc`) VALUES
('F', 'Factura'),
('N', 'Nota de Credito'),
('V', 'Nota de Venta'); -- Agregado como ejemplo

-- Dimensión: `tbl_auxiliar` (Clientes)
INSERT IGNORE INTO `tbl_auxiliar` (`CodAux`, `NomAux`, `RutAux`) VALUES
('96802420', 'OTRACO CHILE S.A.', '96.802.420-5'),
('77268080', 'DUNCAN INGENIERIA INDUSTRIAL LTDA.', '77.268.080-5'),
('96731890', 'CARTULINAS CMPC SPA', '96.731.890-6'),
('76240120', 'RELIX S.A.', '76.240.120-7'),
('76938110', 'EMPRESA DEPURADORA DE AGUAS SERVIDAS LTDA', '76.938.110-4'),
('OTR001', 'Constructora EL SOL S.A.', '88.123.456-7'),
('AUX002', 'Servicios Industriales ABC Ltda.', '76.543.210-9');

-- Dimensión: `tbl_ceco` (Centros de Costo)
INSERT IGNORE INTO `tbl_ceco` (`CodiCC`, `DescCC`, `NivelCC`, `Activo`) VALUES
('3-2-02', 'Centro de Costo Operaciones División 2', 2, 1),
('3-1-02', 'Centro de Costo Operaciones División 1', 2, 1),
('ADM001', 'Centro de Costo Administración', 1, 1),
('FIN001', 'Centro de Costo Finanzas', 1, 1);

-- Dimensión: `tbl_vendedor` (Vendedores)
INSERT IGNORE INTO `tbl_vendedor` (`CodVendedor`, `Vendedor`, `Zona`, `Pais`, `Region`) VALUES
('3202', 'MARCO SCHIAFFINO', 'Centro', 'Chile', 'Metropolitana'),
('3102', 'LUIS ARAYA', 'Norte', 'Chile', 'Antofagasta'),
('VEN003', 'ANA SOTO', 'Sur', 'Chile', 'BioBío'),
('VEN004', 'PEDRO RAMIREZ', 'Centro', 'Chile', 'Valparaíso');

-- Dimensión: `tbl_proserv` (Productos/Servicios)
-- Mapeo de los productos/servicios de tu data original a códigos únicos
INSERT IGNORE INTO `tbl_proserv` (`Cod_Product`, `Producto_o_Servicio`) VALUES
('PS001', 'OUTPUT CARRIER OC3F-1.900-3.240-18'),
('PS002', 'ARRIENDO DE EQUIPO BARRENADOR PORTATIL'),
('PS003', 'ARRIENDO DE EQUIPO BARRENADOR PORTATIL B'),
('PS004', 'SERVICIO DE TORQUE DE PERNOS DE BASE REF'),
('PS005', 'ARRIENDO DE EQUIPO LLAVE DE TORQUE HIDRA'),
('PS006', 'SERVICIO DE TORQUE DE PERNOS SEGUN INDIC'),
('PS007', 'MANTENIMIENTO PREVENTIVO MAQUINARIA X'),
('PS008', 'CONSULTORIA TECNICA ESPECIALIZADA');


-- --------------------------------------------------------
-- INSERCIÓN DE DATOS EN LA TABLA DE HECHOS: `datafacturacion`
-- (Los Folios se generan automáticamente si el AUTO_INCREMENT fue configurado.
--  Si quieres mantener tus folios originales, puedes insertar el valor en la columna `Folio` y
--  asegúrate de que el `AUTO_INCREMENT` de la tabla en el script de creación fue `AUTO_INCREMENT=3008`
--  o el valor inicial deseado.)
-- --------------------------------------------------------

INSERT INTO `datafacturacion` (
    `TipoDocum`, `NumFacturaNC`, `Fecha`, `FechaVenc`, `CentroDeCosto_FK`, `OC`,
    `CodAux_FK`, `NetoAfecto`, `Iva`, `Total`, `Estado`, `NumeroInterno`,
    `CodVendedor_FK`, `NotaVtaN`, `AñoEmision`, `MES`, `DIA`, `TieneNC`, `Cod_Producto_FK`
) VALUES
-- Registros de tu primera entrega, adaptados a la nueva estructura:
('F', NULL, '2012-04-20', '2012-05-20', '3-2-02', '102523',
 '96802420', 447104.00, 84950.00, 532054.00, 'V', 3,
 '3202', 0, 2012, 4, 20, 'No', 'PS001'),
('F', NULL, '2012-04-23', '2012-05-23', '3-2-02', '4191',
 '77268080', 1250000.00, 237500.00, 1487500.00, 'V', 4,
 '3202', 13, 2012, 4, 23, 'No', 'PS002'),
('F', NULL, '2012-04-24', '2012-05-24', '3-2-02', '4303',
 '77268080', 2000000.00, 380000.00, 2380000.00, 'V', 5,
 '3202', 14, 2012, 4, 24, 'No', 'PS003'),
('F', NULL, '2012-04-24', '2012-05-24', '3-1-02', '4900716652',
 '96731890', 1100000.00, 209000.00, 1309000.00, 'V', 6,
 '3102', 15, 2012, 4, 24, 'No', 'PS004'),
('F', NULL, '2012-04-24', '2012-05-24', '3-1-02', '963',
 '76240120', 2500000.00, 475000.00, 2975000.00, 'V', 7,
 '3102', 17, 2012, 4, 24, 'No', 'PS005'),
('F', NULL, '2012-04-24', '2012-05-24', '3-1-02', 'EDAS-0321-12',
 '76938110', 380000.00, 72200.00, 452200.00, 'V', 8,
 '3102', 16, 2012, 4, 24, 'No', 'PS006');

-- Nuevos registros para probar funciones y triggers
-- Factura adicional para probar la inserción con SP
CALL `sp_insertar_factura_completa`(
    'F', NULL, '2023-10-15', '2023-11-15', 'ADM001', 'PO1234',
    'OTR001', 500000.00, fn_calcular_iva(500000.00, 0.19), 595000.00, 'V', 9,
    'VEN003', 100, 'No', 'PS007'
);

-- Simular una Nota de Crédito para una factura existente (Folio 3002 si el auto_increment lo asigna)
-- El Folio de esta NC será el siguiente disponible (ej. 3009 si se insertan 8 registros antes)
-- El trigger 'trg_actualizar_tiene_nc_en_factura' debería actualizar la factura original (con Folio 3002)
-- para indicar que tiene una NC.
INSERT INTO `datafacturacion` (
    `TipoDocum`, `NumFacturaNC`, `Fecha`, `FechaVenc`, `CentroDeCosto_FK`, `OC`,
    `CodAux_FK`, `NetoAfecto`, `Iva`, `Total`, `Estado`, `NumeroInterno`,
    `CodVendedor_FK`, `NotaVtaN`, `AñoEmision`, `MES`, `DIA`, `TieneNC`, `Cod_Producto_FK`
) VALUES
('N', '3002', '2012-05-10', '2012-06-10', '3-2-02', '102523',
 '96802420', -100000.00, -19000.00, -119000.00, 'V', 10,
 '3202', 0, 2012, 5, 10, 'No', 'PS001');

-- Otra factura de ejemplo
CALL `sp_insertar_factura_completa`(
    'F', NULL, '2024-01-20', '2024-02-20', 'FIN001', 'PO5678',
    'AUX002', 750000.00, fn_calcular_iva(750000.00, 0.19), 892500.00, 'V', 11,
    'VEN004', 200, 'No', 'PS008'
);


-- Reactivar las verificaciones de claves foráneas al finalizar la inserción
SET FOREIGN_KEY_CHECKS = 1;

-- Pruebas rápidas (opcional, para verificar datos)
SELECT * FROM `vw_facturacion_detallada` LIMIT 5;
SELECT * FROM `vw_ventas_por_vendedor`;
SELECT * FROM `vw_facturacion_por_cliente`;
SELECT * FROM `vw_facturas_con_nota_credito`;

SELECT fn_obtener_nombre_mes(11);
SELECT fn_calcular_iva(1000, 0.19);

CALL sp_obtener_ventas_por_rango_fechas('2012-04-01', '2012-04-30');

-- Probar trigger de auditoría: Cambiar el estado de una factura (ej., la que insertamos con Folio 3002)
-- NOTA: El Folio exacto dependerá de cómo el AUTO_INCREMENT se haya comportado.
-- Puedes verificar el Folio más bajo con SELECT MIN(Folio) FROM datafacturacion;
-- o el Folio de la primera factura con SELECT Folio FROM datafacturacion WHERE TipoDocum = 'F' LIMIT 1;
-- Asumiendo que el Folio 3002 es uno de los primeros insertados:
-- UPDATE `datafacturacion` SET `Estado` = 'N' WHERE `Folio` = 3002;
-- SELECT * FROM `log_cambios_facturas`;

-- Después de ejecutar este script, puedes verificar la tabla log_cambios_facturas para ver el registro de auditoría.
-- Y verificar la factura original con Folio 3002 para ver si TieneNC cambió a 'Sí'.
-- SELECT Folio, TieneNC FROM datafacturacion WHERE Folio = 3002;