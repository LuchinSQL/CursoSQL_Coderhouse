-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: facturacion
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `datafacturacion`
--

DROP TABLE IF EXISTS `datafacturacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `datafacturacion` (
  `TipoDocum` varchar(50) DEFAULT NULL,
  `Folio` int NOT NULL AUTO_INCREMENT,
  `NumFacturaNC` varchar(50) DEFAULT NULL,
  `Fecha` date DEFAULT NULL,
  `FechaVenc` date DEFAULT NULL,
  `CentroDeCosto` varchar(100) DEFAULT NULL,
  `OC` varchar(50) DEFAULT NULL,
  `CodAux` varchar(50) DEFAULT NULL,
  `NomAux` varchar(100) DEFAULT NULL,
  `RutAux` varchar(20) DEFAULT NULL,
  `NetoAfecto` decimal(10,2) DEFAULT NULL,
  `Iva` decimal(10,2) DEFAULT NULL,
  `Total` decimal(10,2) DEFAULT NULL,
  `Estado` varchar(50) DEFAULT NULL,
  `NumeroInterno` int DEFAULT NULL,
  `CodVendedor` varchar(50) DEFAULT NULL,
  `NotaVtaN` int DEFAULT NULL,
  `AñoEmision` int DEFAULT NULL,
  `MES` int DEFAULT NULL,
  `DIA` int DEFAULT NULL,
  `TieneNC` varchar(10) DEFAULT NULL,
  `ProductoOServicio` varchar(100) DEFAULT NULL,
  `Vendedor` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Folio`)
) ENGINE=InnoDB AUTO_INCREMENT=3008 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `datafacturacion`
--

LOCK TABLES `datafacturacion` WRITE;
/*!40000 ALTER TABLE `datafacturacion` DISABLE KEYS */;
INSERT INTO `datafacturacion` VALUES ('F',3002,NULL,'2012-04-20','2012-05-20','3-2-02','102523','96802420','OTRACO CHILE S.A.','96.802.420-5',447104.00,84950.00,532054.00,'V',3,'3202',0,2012,4,20,NULL,'OUTPUT CARRIER OC3F-1.900-3.240-18','MARCO SCHIAFFINO'),('F',3003,NULL,'2012-04-23','2012-05-23','3-2-02','4191','77268080','DUNCAN INGENIERIA INDUSTRIAL LTDA.','77.268.080-5',1250000.00,237500.00,1487500.00,'V',4,'3202',13,2012,4,23,NULL,'ARRIENDO DE EQUIPO BARRENADOR PORTATIL,','MARCO SCHIAFFINO'),('F',3004,NULL,'2012-04-24','2012-05-24','3-2-02','4303','77268080','DUNCAN INGENIERIA INDUSTRIAL LTDA.','77.268.080-5',2000000.00,380000.00,2380000.00,'V',5,'3202',14,2012,4,24,NULL,'ARRIENDO DE EQUIPO BARRENADOR PORTATIL B','MARCO SCHIAFFINO'),('F',3005,NULL,'2012-04-24','2012-05-24','3-1-02','4900716652','96731890','CARTULINAS CMPC SPA','96.731.890-6',1100000.00,209000.00,1309000.00,'V',6,'3102',15,2012,4,24,NULL,'SERVICIO DE TORQUE DE PERNOS DE BASE REF','LUIS ARAYA'),('F',3006,NULL,'2012-04-24','2012-05-24','3-1-02','963','76240120','RELIX S.A.','76.240.120-7',2500000.00,475000.00,2975000.00,'V',7,'3102',17,2012,4,24,NULL,'ARRIENDO DE EQUIPO LLAVE DE TORQUE HIDRA','LUIS ARAYA'),('F',3007,NULL,'2012-04-24','2012-05-24','3-1-02','EDAS-0321-12','76938110','EMPRESA DEPURADORA DE AGUAS SERVIDAS LTDA','76.938.110-4',380000.00,72200.00,452200.00,'V',8,'3102',16,2012,4,24,NULL,'SERVICIO DE TORQUE DE PERNOS SEGUN INDIC','LUIS ARAYA');
/*!40000 ALTER TABLE `datafacturacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl_auxiliar`
--

DROP TABLE IF EXISTS `tbl_auxiliar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_auxiliar` (
  `CodAux` varchar(9) NOT NULL,
  `NomAux` varchar(255) DEFAULT NULL,
  `RutAux` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`CodAux`),
  UNIQUE KEY `RutAux` (`RutAux`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_auxiliar`
--

LOCK TABLES `tbl_auxiliar` WRITE;
/*!40000 ALTER TABLE `tbl_auxiliar` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_auxiliar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl_ceco`
--

DROP TABLE IF EXISTS `tbl_ceco`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_ceco` (
  `CodiCC` varchar(50) NOT NULL,
  `DescCC` varchar(255) DEFAULT NULL,
  `NivelCC` int DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`CodiCC`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_ceco`
--

LOCK TABLES `tbl_ceco` WRITE;
/*!40000 ALTER TABLE `tbl_ceco` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_ceco` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl_facturas`
--

DROP TABLE IF EXISTS `tbl_facturas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_facturas` (
  `TipoDocum` varchar(1) DEFAULT NULL,
  `DescDoc` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_facturas`
--

LOCK TABLES `tbl_facturas` WRITE;
/*!40000 ALTER TABLE `tbl_facturas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_facturas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl_proserv`
--

DROP TABLE IF EXISTS `tbl_proserv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_proserv` (
  `Cod_Product` varchar(10) NOT NULL,
  `Producto_o_Servicio` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Cod_Product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_proserv`
--

LOCK TABLES `tbl_proserv` WRITE;
/*!40000 ALTER TABLE `tbl_proserv` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_proserv` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl_vendedor`
--

DROP TABLE IF EXISTS `tbl_vendedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_vendedor` (
  `CodVendedor` varchar(50) NOT NULL,
  `Vendedor` varchar(255) DEFAULT NULL,
  `Zona` varchar(100) DEFAULT NULL,
  `Pais` varchar(100) DEFAULT NULL,
  `Region` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`CodVendedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_vendedor`
--

LOCK TABLES `tbl_vendedor` WRITE;
/*!40000 ALTER TABLE `tbl_vendedor` DISABLE KEYS */;
/*!40000 ALTER TABLE `tbl_vendedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'facturacion'
--

--
-- Dumping routines for database 'facturacion'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-10 12:43:00
