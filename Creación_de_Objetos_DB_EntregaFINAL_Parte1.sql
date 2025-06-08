-- Este script realiza las siguientes acciones:
-- 1. Desactiva las verificaciones de claves foráneas para permitir un DROP seguro.
-- 2. Elimina (DROP) los objetos de la base de datos si ya existen, en el orden correcto de dependencia.
-- 3. Crea las tablas de dimensión (tbl_auxiliar, tbl_ceco, tbl_facturas_tipo, tbl_proserv, tbl_vendedor).
-- 4. Crea la tabla de hechos (datafacturacion) con las claves foráneas hacia las tablas de dimensión.
-- 5. Crea una tabla de auditoría (log_cambios_facturas).
-- 6. Crea las Vistas para consultas específicas.
-- 7. Crea las Funciones personalizadas.
-- 8. Crea los Stored Procedures para operaciones comunes.
-- 9. Crea los Triggers para automatizar procesos y mantener la integridad.
-- 10. Reactiva las verificaciones de claves foráneas.

-- Selecciona la base de datos a utilizar (asegúrate de que exista o créala)
-- CREATE DATABASE IF NOT EXISTS `facturacion`;
USE `facturacion`;

-- Desactivar temporalmente las verificaciones de claves foráneas para facilitar el DROP
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- 2. ELIMINACIÓN (DROP) DE OBJETOS EXISTENTES
-- (Orden inverso de dependencia para evitar problemas de FK)
-- --------------------------------------------------------

-- Eliminar Triggers
DROP TRIGGER IF EXISTS `trg_auditoria_cambios_factura`;
DROP TRIGGER IF EXISTS `trg_actualizar_tiene_nc_en_factura`;

-- Eliminar Stored Procedures
DROP PROCEDURE IF EXISTS `sp_insertar_factura_completa`;
DROP PROCEDURE IF EXISTS `sp_actualizar_estado_documento`;
DROP PROCEDURE IF EXISTS `sp_obtener_ventas_por_rango_fechas`;

-- Eliminar Funciones
DROP FUNCTION IF EXISTS `fn_obtener_nombre_mes`;
DROP FUNCTION IF EXISTS `fn_calcular_iva`;

-- Eliminar Vistas
DROP VIEW IF EXISTS `vw_facturacion_detallada`;
DROP VIEW IF EXISTS `vw_ventas_por_vendedor`;
DROP VIEW IF EXISTS `vw_facturacion_por_cliente`;
DROP VIEW IF EXISTS `vw_resumen_mensual_facturacion`;
DROP VIEW IF EXISTS `vw_facturas_con_nota_credito`;

-- Eliminar Tablas
DROP TABLE IF EXISTS `datafacturacion`;
DROP TABLE IF EXISTS `tbl_auxiliar`;
DROP TABLE IF EXISTS `tbl_ceco`;
DROP TABLE IF EXISTS `tbl_facturas_tipo`;
DROP TABLE IF EXISTS `tbl_proserv`;
DROP TABLE IF EXISTS `tbl_vendedor`;
DROP TABLE IF EXISTS `log_cambios_facturas`;

-- Reactivar las verificaciones de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;

-- --------------------------------------------------------
-- 3. CREACIÓN DE TABLAS
-- (Dimensiones primero, luego Tabla de Hechos y Tablas Auxiliares)
-- --------------------------------------------------------

-- Dimensión: `tbl_auxiliar` (Clientes)
CREATE TABLE `tbl_auxiliar` (
  `CodAux` VARCHAR(50) NOT NULL COMMENT 'Código único del Cliente',
  `NomAux` VARCHAR(255) DEFAULT NULL COMMENT 'Razón Social o Nombre del Cliente',
  `RutAux` VARCHAR(20) DEFAULT NULL UNIQUE COMMENT 'RUT del cliente con dígito verificador (único)',
  PRIMARY KEY (`CodAux`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dimensión: `tbl_ceco` (Centros de Costo)
CREATE TABLE `tbl_ceco` (
  `CodiCC` VARCHAR(100) NOT NULL COMMENT 'Código único del Centro de Costo',
  `DescCC` VARCHAR(255) DEFAULT NULL COMMENT 'Descripción del Centro de Costo o Unidad de Negocio Facturado',
  `NivelCC` INT DEFAULT NULL COMMENT 'Nivel jerárquico del Centro de Costo',
  `Activo` TINYINT(1) DEFAULT NULL COMMENT 'Indica si el Centro de Costo está Activo (1: Sí, 0: No)',
  PRIMARY KEY (`CodiCC`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dimensión: `tbl_facturas_tipo` (Tipos de Documento)
CREATE TABLE `tbl_facturas_tipo` (
  `TipoDocum` VARCHAR(1) NOT NULL COMMENT 'Código del Tipo de Documento (ej. F para Factura, N para Nota de Crédito)',
  `DescDoc` VARCHAR(255) DEFAULT NULL COMMENT 'Nombre descriptivo del Documento',
  PRIMARY KEY (`TipoDocum`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dimensión: `tbl_proserv` (Productos/Servicios)
CREATE TABLE `tbl_proserv` (
  `Cod_Product` VARCHAR(10) NOT NULL COMMENT 'Código único del Producto o Servicio',
  `Producto_o_Servicio` VARCHAR(255) DEFAULT NULL COMMENT 'Nombre descriptivo del Producto o Servicio',
  PRIMARY KEY (`Cod_Product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dimensión: `tbl_vendedor` (Vendedores)
CREATE TABLE `tbl_vendedor` (
  `CodVendedor` VARCHAR(50) NOT NULL COMMENT 'Código único del Vendedor',
  `Vendedor` VARCHAR(255) DEFAULT NULL COMMENT 'Nombre completo del Vendedor',
  `Zona` VARCHAR(100) DEFAULT NULL COMMENT 'Zona de Venta asignada (ej. Norte, Sur, Centro de Chile)',
  `Pais` VARCHAR(100) DEFAULT NULL COMMENT 'País del vendedor',
  `Region` VARCHAR(100) DEFAULT NULL COMMENT 'Región de Chile',
  PRIMARY KEY (`CodVendedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla de Hechos: `datafacturacion`
CREATE TABLE `datafacturacion` (
  `Folio` INT NOT NULL AUTO_INCREMENT COMMENT 'Número de Folio único del Documento (Factura o Nota de Crédito)',
  `TipoDocum` VARCHAR(1) DEFAULT NULL COMMENT 'Tipo de documento (F: Factura, N: Nota de Crédito)',
  `NumFacturaNC` VARCHAR(50) DEFAULT NULL COMMENT 'Número de Factura al que hace referencia una Nota de Crédito',
  `Fecha` DATE DEFAULT NULL COMMENT 'Fecha de Emisión del Documento',
  `FechaVenc` DATE DEFAULT NULL COMMENT 'Fecha de Vencimiento del Documento',
  `CentroDeCosto_FK` VARCHAR(100) DEFAULT NULL COMMENT 'Código del Centro de Costo',
  `OC` VARCHAR(50) DEFAULT NULL COMMENT 'Número de Orden de Compra del Cliente',
  `CodAux_FK` VARCHAR(50) DEFAULT NULL COMMENT 'Código del Cliente (Auxiliar)',
  `NetoAfecto` DECIMAL(10,2) DEFAULT NULL COMMENT 'Valor Neto Afecto de la Factura o Nota de Crédito',
  `Iva` DECIMAL(10,2) DEFAULT NULL COMMENT 'Valor del IVA de la Factura o Nota de Crédito',
  `Total` DECIMAL(10,2) DEFAULT NULL COMMENT 'Valor Bruto (Total) de la Factura o Nota de Crédito',
  `Estado` VARCHAR(50) DEFAULT NULL COMMENT 'Estado del documento (V: Vigente, N: Nulo)',
  `NumeroInterno` INT DEFAULT NULL COMMENT 'Número Interno del sistema o software',
  `CodVendedor_FK` VARCHAR(50) DEFAULT NULL COMMENT 'Código del Vendedor',
  `NotaVtaN` INT DEFAULT NULL COMMENT 'Número foliado de la Nota de Venta (si aplica)',
  `AñoEmision` INT DEFAULT NULL COMMENT 'Año de Emisión de la Factura',
  `MES` INT DEFAULT NULL COMMENT 'Mes de Emisión de la Factura',
  `DIA` INT DEFAULT NULL COMMENT 'Día de Emisión de la Factura',
  `TieneNC` VARCHAR(10) DEFAULT 'No' COMMENT 'Indica si la Factura tiene una Nota de Crédito Emitida (Sí/No)',
  `Cod_Producto_FK` VARCHAR(10) DEFAULT NULL COMMENT 'Código del Producto o Servicio',
  PRIMARY KEY (`Folio`),
  CONSTRAINT `fk_tipo_docum` FOREIGN KEY (`TipoDocum`) REFERENCES `tbl_facturas_tipo` (`TipoDocum`),
  CONSTRAINT `fk_centro_costo` FOREIGN KEY (`CentroDeCosto_FK`) REFERENCES `tbl_ceco` (`CodiCC`),
  CONSTRAINT `fk_cod_aux` FOREIGN KEY (`CodAux_FK`) REFERENCES `tbl_auxiliar` (`CodAux`),
  CONSTRAINT `fk_cod_vendedor` FOREIGN KEY (`CodVendedor_FK`) REFERENCES `tbl_vendedor` (`CodVendedor`),
  CONSTRAINT `fk_cod_producto` FOREIGN KEY (`Cod_Producto_FK`) REFERENCES `tbl_proserv` (`Cod_Product`)
) ENGINE=InnoDB AUTO_INCREMENT=3008 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE log_cambios_facturas (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    folio_factura INT COMMENT 'Folio del documento de factura modificado',
    campo_modificado VARCHAR(100) COMMENT 'Nombre del campo que fue modificado',
    valor_anterior VARCHAR(255) COMMENT 'Valor del campo antes de la modificación',
    valor_nuevo VARCHAR(255) COMMENT 'Valor del campo después de la modificación',
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del cambio',
    usuario_cambio VARCHAR(255) COMMENT 'Usuario que realizó el cambio'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- --------------------------------------------------------
-- 4. CREACIÓN DE VISTAS
-- --------------------------------------------------------

-- Vista: `vw_facturacion_detallada`
-- Proporciona una vista consolidada de toda la información de facturación
CREATE VIEW `vw_facturacion_detallada` AS
SELECT
    df.Folio,
    ft.DescDoc AS TipoDocumento,
    df.NumFacturaNC,
    df.Fecha,
    df.FechaVenc,
    cc.DescCC AS CentroDeCosto,
    df.OC,
    ta.NomAux AS NombreCliente,
    ta.RutAux AS RutCliente,
    df.NetoAfecto,
    df.Iva,
    df.Total,
    df.Estado,
    df.NumeroInterno,
    tv.Vendedor AS NombreVendedor,
    df.NotaVtaN,
    df.AñoEmision,
    df.MES,
    df.DIA,
    df.TieneNC,
    tp.Producto_o_Servicio AS DescripcionProductoServicio,
    tv.Zona AS ZonaVendedor,
    tv.Region AS RegionVendedor
FROM
    datafacturacion df
LEFT JOIN
    tbl_facturas_tipo ft ON df.TipoDocum = ft.TipoDocum
LEFT JOIN
    tbl_ceco cc ON df.CentroDeCosto_FK = cc.CodiCC
LEFT JOIN
    tbl_auxiliar ta ON df.CodAux_FK = ta.CodAux
LEFT JOIN
    tbl_vendedor tv ON df.CodVendedor_FK = tv.CodVendedor
LEFT JOIN
    tbl_proserv tp ON df.Cod_Producto_FK = tp.Cod_Product;


-- Vista: `vw_ventas_por_vendedor`
-- Muestra el total de ventas por cada vendedor
CREATE VIEW `vw_ventas_por_vendedor` AS
SELECT
    tv.Vendedor,
    SUM(df.NetoAfecto) AS TotalNeto,
    SUM(df.Iva) AS TotalIva,
    SUM(df.Total) AS TotalBruto,
    COUNT(df.Folio) AS CantidadDocumentos
FROM
    datafacturacion df
JOIN
    tbl_vendedor tv ON df.CodVendedor_FK = tv.CodVendedor
WHERE
    df.TipoDocum = 'F' -- Solo Facturas para ventas
GROUP BY
    tv.Vendedor
ORDER BY
    TotalBruto DESC;


-- Vista: `vw_facturacion_por_cliente`
-- Muestra el total facturado por cliente
CREATE VIEW `vw_facturacion_por_cliente` AS
SELECT
    ta.NomAux AS NombreCliente,
    ta.RutAux AS RutCliente,
    SUM(df.NetoAfecto) AS TotalNetoFacturado,
    SUM(df.Iva) AS TotalIvaFacturado,
    SUM(df.Total) AS TotalBrutoFacturado,
    COUNT(df.Folio) AS CantidadDocumentos
FROM
    datafacturacion df
JOIN
    tbl_auxiliar ta ON df.CodAux_FK = ta.CodAux
WHERE
    df.TipoDocum = 'F' -- Considerar solo facturas
GROUP BY
    ta.NomAux, ta.RutAux
ORDER BY
    TotalBrutoFacturado DESC;


-- Vista: `vw_resumen_mensual_facturacion`
-- Total facturado por mes y año
CREATE VIEW `vw_resumen_mensual_facturacion` AS
SELECT
    df.AñoEmision AS Año,
    df.MES AS MesNumero,
    fn_obtener_nombre_mes(df.MES) AS NombreMes, -- Utiliza la función personalizada
    SUM(df.NetoAfecto) AS TotalNetoMensual,
    SUM(df.Iva) AS TotalIvaMensual,
    SUM(df.Total) AS TotalBrutoMensual,
    COUNT(df.Folio) AS CantidadDocumentosMensual
FROM
    datafacturacion df
WHERE
    df.TipoDocum = 'F' -- Solo Facturas
GROUP BY
    df.AñoEmision, df.MES
ORDER BY
    df.AñoEmision ASC, df.MES ASC;


-- Vista: `vw_facturas_con_nota_credito`
-- Lista las facturas que tienen una nota de crédito asociada
CREATE VIEW `vw_facturas_con_nota_credito` AS
SELECT
    df.Folio AS FolioFactura,
    df.Fecha AS FechaFactura,
    df.NetoAfecto AS NetoFactura,
    df.Total AS TotalFactura,
    ta.NomAux AS NombreCliente,
    nc.Folio AS FolioNotaCredito,
    nc.Fecha AS FechaNotaCredito,
    nc.NetoAfecto AS NetoNotaCredito,
    nc.Total AS TotalNotaCredito
FROM
    datafacturacion df
JOIN
    datafacturacion nc ON df.Folio = nc.NumFacturaNC AND nc.TipoDocum = 'N'
LEFT JOIN
    tbl_auxiliar ta ON df.CodAux_FK = ta.CodAux
WHERE
    df.TipoDocum = 'F' AND df.TieneNC = 'Sí';


-- --------------------------------------------------------
-- 5. CREACIÓN DE FUNCIONES
-- --------------------------------------------------------

DELIMITER //

CREATE FUNCTION fn_obtener_nombre_mes(mes_num INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE nombre_mes VARCHAR(20);

    CASE mes_num
        WHEN 1 THEN SET nombre_mes = 'Enero';
        WHEN 2 THEN SET nombre_mes = 'Febrero';
        WHEN 3 THEN SET nombre_mes = 'Marzo';
        WHEN 4 THEN SET nombre_mes = 'Abril';
        WHEN 5 THEN SET nombre_mes = 'Mayo';
        WHEN 6 THEN SET nombre_mes = 'Junio';
        WHEN 7 THEN SET nombre_mes = 'Julio';
        WHEN 8 THEN SET nombre_mes = 'Agosto';
        WHEN 9 THEN SET nombre_mes = 'Septiembre';
        WHEN 10 THEN SET nombre_mes = 'Octubre';
        WHEN 11 THEN SET nombre_mes = 'Noviembre';
        WHEN 12 THEN SET nombre_mes = 'Diciembre';
        ELSE SET nombre_mes = 'Mes Inválido';
    END CASE;

    RETURN nombre_mes;
END;
//

DELIMITER //

CREATE FUNCTION fn_calcular_iva(p_neto DECIMAL(10,2), p_tasa_iva DECIMAL(5,4))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_neto * p_tasa_iva;
END;
//

DELIMITER ;

-- --------------------------------------------------------
-- 6. CREACIÓN DE STORED PROCEDURES
-- --------------------------------------------------------

DELIMITER //

-- Stored Procedure: `sp_insertar_factura_completa`
-- Inserta un nuevo registro en `datafacturacion` con validaciones
CREATE PROCEDURE `sp_insertar_factura_completa` (
    IN p_TipoDocum VARCHAR(1),
    IN p_NumFacturaNC VARCHAR(50),
    IN p_Fecha DATE,
    IN p_FechaVenc DATE,
    IN p_CentroDeCosto_FK VARCHAR(100),
    IN p_OC VARCHAR(50),
    IN p_CodAux_FK VARCHAR(50),
    IN p_NetoAfecto DECIMAL(10,2),
    IN p_Iva DECIMAL(10,2),
    IN p_Total DECIMAL(10,2),
    IN p_Estado VARCHAR(50),
    IN p_NumeroInterno INT,
    IN p_CodVendedor_FK VARCHAR(50),
    IN p_NotaVtaN INT,
    IN p_TieneNC VARCHAR(10),
    IN p_Cod_Producto_FK VARCHAR(10)
)
BEGIN
    -- Validaciones de FKs
    IF NOT EXISTS (SELECT 1 FROM tbl_facturas_tipo WHERE TipoDocum = p_TipoDocum) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Tipo de documento inválido. Debe existir en tbl_facturas_tipo.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tbl_auxiliar WHERE CodAux = p_CodAux_FK) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Código de auxiliar (cliente) inválido. Debe existir en tbl_auxiliar.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tbl_ceco WHERE CodiCC = p_CentroDeCosto_FK) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Código de Centro de Costo inválido. Debe existir en tbl_ceco.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tbl_vendedor WHERE CodVendedor = p_CodVendedor_FK) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Código de Vendedor inválido. Debe existir en tbl_vendedor.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tbl_proserv WHERE Cod_Product = p_Cod_Producto_FK) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Código de Producto/Servicio inválido. Debe existir en tbl_proserv.';
    END IF;

    -- Insertar el nuevo registro en datafacturacion
    INSERT INTO `datafacturacion` (
        `TipoDocum`, `NumFacturaNC`, `Fecha`, `FechaVenc`, `CentroDeCosto_FK`, `OC`,
        `CodAux_FK`, `NetoAfecto`, `Iva`, `Total`, `Estado`, `NumeroInterno`,
        `CodVendedor_FK`, `NotaVtaN`, `AñoEmision`, `MES`, `DIA`, `TieneNC`, `Cod_Producto_FK`
    ) VALUES (
        p_TipoDocum, p_NumFacturaNC, p_Fecha, p_FechaVenc, p_CentroDeCosto_FK, p_OC,
        p_CodAux_FK, p_NetoAfecto, p_Iva, p_Total, p_Estado, p_NumeroInterno,
        p_CodVendedor_FK, p_NotaVtaN, YEAR(p_Fecha), MONTH(p_Fecha), DAY(p_Fecha), p_TieneNC, p_Cod_Producto_FK
    );
END //

-- Stored Procedure: `sp_actualizar_estado_documento`
-- Actualiza el campo `Estado` de un documento de facturación
DELIMITER //

CREATE PROCEDURE sp_actualizar_estado_documento (
    IN p_Folio INT,
    IN p_NuevoEstado VARCHAR(50)
)
BEGIN
    DECLARE old_estado VARCHAR(50);

    -- Obtener el estado actual para el log de auditoría
    SELECT Estado INTO old_estado FROM datafacturacion WHERE Folio = p_Folio;

    -- Actualizar estado del documento
    UPDATE datafacturacion
    SET Estado = p_NuevoEstado
    WHERE Folio = p_Folio;

    -- Si quisieras hacer log manual sin trigger, descomenta esto:
    -- IF old_estado <> p_NuevoEstado THEN
    --     INSERT INTO log_cambios_facturas (
    --         folio_factura, campo_modificado, valor_anterior, valor_nuevo, usuario_cambio
    --     ) VALUES (
    --         p_Folio, 'Estado', old_estado, p_NuevoEstado, USER()
    --     );
    -- END IF;
END;
//

-- PROCEDIMIENTO: Obtener Ventas por Rango de Fechas
CREATE PROCEDURE sp_obtener_ventas_por_rango_fechas (
    IN p_FechaInicio DATE,
    IN p_FechaFin DATE
)
BEGIN
    SELECT
        df.AñoEmision AS Año,
        fn_obtener_nombre_mes(df.MES) AS Mes,
        SUM(df.NetoAfecto) AS TotalNeto,
        SUM(df.Iva) AS TotalIva,
        SUM(df.Total) AS TotalBruto,
        COUNT(df.Folio) AS CantidadDocumentos
    FROM
        datafacturacion df
    WHERE
        df.Fecha BETWEEN p_FechaInicio AND p_FechaFin
        AND df.TipoDocum = 'F' -- Solo Facturas
    GROUP BY
        df.AñoEmision, df.MES
    ORDER BY
        df.AñoEmision, df.MES;
END;
//

DELIMITER ;

-- --------------------------------------------------------
-- 7. CREACIÓN DE TRIGGERS
-- --------------------------------------------------------

DELIMITER //

-- Trigger: `trg_auditoria_cambios_factura`
-- Registra cambios importantes en la tabla `datafacturacion`
CREATE TRIGGER `trg_auditoria_cambios_factura`
AFTER UPDATE ON `datafacturacion`
FOR EACH ROW
BEGIN
    -- Registrar cambios en el campo 'Estado'
    IF OLD.Estado <> NEW.Estado THEN
        INSERT INTO `log_cambios_facturas` (folio_factura, campo_modificado, valor_anterior, valor_nuevo, usuario_cambio)
        VALUES (NEW.Folio, 'Estado', OLD.Estado, NEW.Estado, USER());
    END IF;

    -- Registrar cambios en 'NetoAfecto'
    IF OLD.NetoAfecto <> NEW.NetoAfecto THEN
        INSERT INTO `log_cambios_facturas` (folio_factura, campo_modificado, valor_anterior, valor_nuevo, usuario_cambio)
        VALUES (NEW.Folio, 'NetoAfecto', OLD.NetoAfecto, NEW.NetoAfecto, USER());
    END IF;

    -- Registrar cambios en 'Iva'
    IF OLD.Iva <> NEW.Iva THEN
        INSERT INTO `log_cambios_facturas` (folio_factura, campo_modificado, valor_anterior, valor_nuevo, usuario_cambio)
        VALUES (NEW.Folio, 'Iva', OLD.Iva, NEW.Iva, USER());
    END IF;

    -- Registrar cambios en 'Total'
    IF OLD.Total <> NEW.Total THEN
        INSERT INTO `log_cambios_facturas` (folio_factura, campo_modificado, valor_anterior, valor_nuevo, usuario_cambio)
        VALUES (NEW.Folio, 'Total', OLD.Total, NEW.Total, USER());
    END IF;

    -- Puedes añadir más condiciones para otros campos si es necesario
END //

-- Trigger: `trg_actualizar_tiene_nc_en_factura`
-- Actualiza el campo `TieneNC` de la factura original cuando se inserta una Nota de Crédito
CREATE TRIGGER `trg_actualizar_tiene_nc_en_factura`
AFTER INSERT ON `datafacturacion`
FOR EACH ROW
BEGIN
    -- Si el nuevo registro es una Nota de Crédito y referencia a una factura existente
    IF NEW.TipoDocum = 'N' AND NEW.NumFacturaNC IS NOT NULL THEN
        UPDATE `datafacturacion`
        SET `TieneNC` = 'Sí'
        WHERE `Folio` = NEW.NumFacturaNC
          AND `TipoDocum` = 'F'; -- Asegurarse de que el documento referenciado sea una Factura
    END IF;
END //

DELIMITER ;