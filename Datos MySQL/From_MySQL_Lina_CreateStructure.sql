CREATE DATABASE  IF NOT EXISTS `lina` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `lina`;
-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: lina
-- ------------------------------------------------------
-- Server version	8.0.45

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
-- Table structure for table `linaarti`
--

DROP TABLE IF EXISTS `linaarti`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linaarti` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `articodi` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo Articulo',
  `artrcodi` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Rubro del Articulo',
  `artidesc` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripción del Articulo',
  `artiexan` int NOT NULL DEFAULT '0' COMMENT 'Existencia Anterior Cantidad',
  `artiexfe` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Existencia Anterior Fecha',
  `artipmpe` int NOT NULL DEFAULT '0' COMMENT 'Punto Minimo de Pedido',
  `artiucco` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Costo Ultima Compra',
  `artiucfe` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Ultima Compra',
  `artiucca` int NOT NULL DEFAULT '0' COMMENT 'Cantidad Ultima Compra',
  `artiprec` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Precio de Venta',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`articodi`),
  KEY `idx_arti_articodi` (`articodi`),
  KEY `fk_arti_artr` (`emprcodi`,`artrcodi`),
  CONSTRAINT `fk_arti_artr` FOREIGN KEY (`emprcodi`, `artrcodi`) REFERENCES `linaartr` (`emprcodi`, `artrcodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_arti_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Artículos';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linaartr`
--

DROP TABLE IF EXISTS `linaartr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linaartr` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `artrcodi` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Rubro',
  `artrdesc` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripcion del Rubro',
  `artrsalp` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Salto de Pagina (S/N)',
  `artrsala` int NOT NULL DEFAULT '0' COMMENT 'Renglones Antes',
  `artrsald` int NOT NULL DEFAULT '0' COMMENT 'Renglones Despues',
  `artrsubr` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Caracter de Subrayado',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`artrcodi`),
  KEY `idx_artr_emprcodi` (`emprcodi`),
  KEY `idx_artr_artrcodi` (`artrcodi`),
  CONSTRAINT `fk_artr_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Rubros de Artículos';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaartr_audit_insert` BEFORE INSERT ON `linaartr` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaartr_audit_update` BEFORE UPDATE ON `linaartr` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linabanc`
--

DROP TABLE IF EXISTS `linabanc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linabanc` (
  `bancid` int NOT NULL AUTO_INCREMENT COMMENT 'PK autoincremental linabanc',
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Código de Empresa',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'Código de Cliente',
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Proveedor',
  `bancfech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Movimiento',
  `bancnumc` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante Origen',
  `bancconc` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Concepto',
  `bancdebe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Importe Debito',
  `banchabe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Importe Credito',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`bancid`),
  KEY `fk_banc_clie` (`emprcodi`,`cliecodi`),
  KEY `fk_banc_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_banc_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_banc_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=160 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Movimientos de Bancos';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linabanc_audit_insert` BEFORE INSERT ON `linabanc` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linabanc_audit_update` BEFORE UPDATE ON `linabanc` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linacaja`
--

DROP TABLE IF EXISTS `linacaja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linacaja` (
  `cajaid` int NOT NULL AUTO_INCREMENT COMMENT 'PK autoincremental linacaja',
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Código de Empresa',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Cliente',
  `provcodi` int NOT NULL COMMENT 'Codigo de Proveedor',
  `cajafech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Movmiento',
  `cajanumc` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante Origen',
  `cajaconc` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Concepto',
  `cajadebe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Importe Debito',
  `cajahabe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Importe Credito',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`cajaid`),
  KEY `fk_caja_clie` (`emprcodi`,`cliecodi`),
  KEY `fk_caja_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_caja_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_caja_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1311 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Movimientos de Caja';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linacaja_audit_insert` BEFORE INSERT ON `linacaja` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linacaja_audit_update` BEFORE UPDATE ON `linacaja` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linaclie`
--

DROP TABLE IF EXISTS `linaclie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linaclie` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Cliente',
  `cliename` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Nombre del Cliente',
  `cliesala` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Saldo Anterior',
  `cliefesa` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Saldo Anterior',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`cliecodi`),
  KEY `idx_clie_cliecodi` (`cliecodi`),
  CONSTRAINT `fk_clie_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Clientes';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaclie_audit_insert` BEFORE INSERT ON `linaclie` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaclie_audit_update` BEFORE UPDATE ON `linaclie` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linacode`
--

DROP TABLE IF EXISTS `linacode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linacode` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `cohenume` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `codereng` int NOT NULL DEFAULT '0' COMMENT 'Numero de Renglon',
  `codedesc` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripcion del Concepto',
  `codeunit` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Precio Unitario',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`cohenume`,`codereng`,`emprcodi`,`codmcodi`),
  KEY `fk_code_cohe` (`emprcodi`,`codmcodi`,`cohenume`),
  CONSTRAINT `fk_code_cohe` FOREIGN KEY (`emprcodi`, `codmcodi`, `cohenume`) REFERENCES `linacohe` (`emprcodi`, `codmcodi`, `cohenume`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cobranzas - Detalle';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linacode_audit_insert` BEFORE INSERT ON `linacode` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linacode_audit_update` BEFORE UPDATE ON `linacode` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linacodm`
--

DROP TABLE IF EXISTS `linacodm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linacodm` (
  `codmclpr` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Aplica a <C>liente ó a <P>roveedor',
  `codmdecr` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Es <D>ébito ó <C>rédito',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `codmdesc` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripcion',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`codmclpr`,`codmdecr`,`codmcodi`),
  KEY `idx_codm_codmcodi` (`codmcodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Códigos de Movimiento';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linacodm_audit_insert` BEFORE INSERT ON `linacodm` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linacodm_audit_update` BEFORE UPDATE ON `linacodm` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linacohe`
--

DROP TABLE IF EXISTS `linacohe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linacohe` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `cohenume` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `cohefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Comprobante',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Cliente',
  `cohetota` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Total Comprobante',
  `coheefec` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Cobrado en Efectivo',
  `cohebanc` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Cobrado en Transf. o Deposito',
  `coheobse` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Observaciones',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`codmcodi`,`cohenume`,`emprcodi`),
  KEY `idx_cohe_empr_clie` (`emprcodi`,`cliecodi`) /*!80000 INVISIBLE */,
  KEY `idx_cohe_code` (`emprcodi`,`codmcodi`,`cohenume`),
  CONSTRAINT `fk_cohe_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cobranzas - Cabeceras';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linacohe_audit_insert` BEFORE INSERT ON `linacohe` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linacohe_audit_update` BEFORE UPDATE ON `linacohe` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linactcl`
--

DROP TABLE IF EXISTS `linactcl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linactcl` (
  `ctclid` int NOT NULL AUTO_INCREMENT COMMENT 'PK autoincremental linactcl',
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Cliente',
  `ctclfech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Movimiento',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `ctclnumc` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `ctcldebe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Importe al Debe',
  `ctclhabe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Importe al Haber',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ctclid`),
  KEY `fk_ctcl__clie` (`emprcodi`,`cliecodi`),
  CONSTRAINT `fk_ctcl__clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2570 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cuentas Corrientes de Clientes';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linactcl_audit_insert` BEFORE INSERT ON `linactcl` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linactcl_audit_update` BEFORE UPDATE ON `linactcl` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linactpr`
--

DROP TABLE IF EXISTS `linactpr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linactpr` (
  `ctprid` int NOT NULL AUTO_INCREMENT,
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Proveedor',
  `ctprfech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Movimiento',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `ctprnumc` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `ctprdebe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Importe al Debe',
  `ctprhabe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Importe al Haber',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ctprid`),
  KEY `fk_ctpr_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_ctpr_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=423 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cuentas Corrientes de Proveedores';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linactpr_audit_insert` BEFORE INSERT ON `linactpr` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linactpr_audit_update` BEFORE UPDATE ON `linactpr` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linaempr`
--

DROP TABLE IF EXISTS `linaempr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linaempr` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Empresa',
  `emprname` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Razon Social',
  `emprdire` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Direccion',
  `emprcodp` char(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo Postal',
  `emprloca` varchar(34) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Localidad',
  `emprtele` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Telefono',
  `emprciva` int NOT NULL DEFAULT '0' COMMENT 'Condicion frente a IVA',
  `emprcgan` int NOT NULL DEFAULT '0' COMMENT 'Condicion frente a Ganancias',
  `emprcuit` decimal(11,0) NOT NULL DEFAULT '0' COMMENT 'CUIT',
  `emprunid` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Unidad de Trabajo',
  `emprnume` int NOT NULL DEFAULT '0' COMMENT 'Control (Name+Dire)',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Empresas';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaempr_audit_insert` BEFORE INSERT ON `linaempr` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaempr_audit_update` BEFORE UPDATE ON `linaempr` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linaerro`
--

DROP TABLE IF EXISTS `linaerro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linaerro` (
  `erroid` int NOT NULL AUTO_INCREMENT COMMENT 'PK autoincremental linaerro',
  `errowstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Id. Error',
  `errouser` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Usuario',
  `errodate` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha',
  `errotime` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Hora',
  `erroempr` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Empresa',
  `erronume` int NOT NULL DEFAULT '0' COMMENT 'Número de Error',
  `erromssg` varchar(78) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Mensaje',
  `errosour` varchar(78) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Código fuente',
  `erroline` int NOT NULL DEFAULT '0' COMMENT 'Línea',
  `erroprg0` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 0',
  `erroprg1` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 1',
  `erroprg2` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 2',
  `erroprg3` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 3',
  `erroprg4` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 4',
  `erroprg5` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 5',
  `erroprg6` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 6',
  `erroprg7` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 7',
  `erroprg8` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Nivel 8',
  `erroprg9` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`erroid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Errores de Ejecución';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linafcde`
--

DROP TABLE IF EXISTS `linafcde`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linafcde` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `fchenume` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `fcdereng` int NOT NULL DEFAULT '0' COMMENT 'Renglon del Comprobante',
  `fchefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Movimiento para CARDEX',
  `articodi` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Articulo',
  `fcdedesc` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripcion del Item',
  `fcdecant` int NOT NULL DEFAULT '0' COMMENT 'Cantidad',
  `fcdeunit` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Precio Unitario',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`fchenume`,`fcdereng`,`codmcodi`),
  KEY `fk_fcde_articodi` (`articodi`),
  KEY `fk_fcde_fche` (`emprcodi`,`codmcodi`,`fchenume`),
  CONSTRAINT `fk_fcde_articodi` FOREIGN KEY (`articodi`) REFERENCES `linaarti` (`articodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_fcde_fche` FOREIGN KEY (`emprcodi`, `codmcodi`, `fchenume`) REFERENCES `linafche` (`emprcodi`, `codmcodi`, `fchenume`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Facturación Compras - Detalle';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linafcde_audit_insert` BEFORE INSERT ON `linafcde` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linafcde_audit_update` BEFORE UPDATE ON `linafcde` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linafche`
--

DROP TABLE IF EXISTS `linafche`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linafche` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `fchenume` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `fchefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Comprobante',
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Proveedor',
  `fchetota` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Total Comprobante',
  `fcheobse` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Observaciones',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`fchenume`,`emprcodi`,`codmcodi`),
  KEY `idx_fche_fcde` (`emprcodi`,`codmcodi`,`fchenume`),
  KEY `fk_fche_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_fche_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Facturación Compras - Cabeceras';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linafche_audit_insert` BEFORE INSERT ON `linafche` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linafche_audit_update` BEFORE UPDATE ON `linafche` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linafvde`
--

DROP TABLE IF EXISTS `linafvde`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linafvde` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `fvhenume` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `fvdereng` int NOT NULL DEFAULT '0' COMMENT 'Numero de Renglon',
  `fvhefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Movimiento para CARDEX',
  `articodi` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Articulo',
  `fvdedesc` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripcion del Item',
  `fvdecant` int NOT NULL DEFAULT '0' COMMENT 'Cantidad',
  `fvdeunit` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Unitario',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`codmcodi`,`fvhenume`,`fvdereng`),
  KEY `idx_fvde_articodi` (`articodi`),
  CONSTRAINT `fk_fvde_articodi` FOREIGN KEY (`articodi`) REFERENCES `linaarti` (`articodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_fvde_fvhe` FOREIGN KEY (`emprcodi`, `codmcodi`, `fvhenume`) REFERENCES `linafvhe` (`emprcodi`, `codmcodi`, `fvhenume`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Facturación Ventas - Detalle';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linafvde_audit_insert` BEFORE INSERT ON `linafvde` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linafvde_audit_update` BEFORE UPDATE ON `linafvde` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linafvhe`
--

DROP TABLE IF EXISTS `linafvhe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linafvhe` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `fvhenume` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `fvhefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Comprobante',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Cliente',
  `fvhetota` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Total Comprobante',
  `fvheobse` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Observaciones',
  `fvhereci` int NOT NULL DEFAULT '0' COMMENT 'Numero de Recibo Simultaneo a Factura',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`fvhenume`,`emprcodi`,`codmcodi`),
  KEY `idx_fvhe_codmcodi` (`codmcodi`),
  KEY `idx_fvhe_fvde` (`emprcodi`,`codmcodi`,`fvhenume`),
  KEY `fk_fvde_clie` (`emprcodi`,`cliecodi`),
  CONSTRAINT `fk_fvde_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_fvhe_codmcodi` FOREIGN KEY (`codmcodi`) REFERENCES `linacodm` (`codmcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Facturación Ventas - Cabeceraa';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linafvhe_audit_insert` BEFORE INSERT ON `linafvhe` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linafvhe_audit_update` BEFORE UPDATE ON `linafvhe` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linamixt`
--

DROP TABLE IF EXISTS `linamixt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linamixt` (
  `mixtclav` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `mixtdato` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`mixtclav`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Mixto de Configuración';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linapade`
--

DROP TABLE IF EXISTS `linapade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linapade` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `pahenume` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `padereng` int NOT NULL DEFAULT '0' COMMENT 'Numero de Renglon',
  `padedesc` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripcion del Concepto',
  `padeunit` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Unitario',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`codmcodi`,`pahenume`,`padereng`),
  CONSTRAINT `fk_pade_pahe` FOREIGN KEY (`emprcodi`, `codmcodi`, `pahenume`) REFERENCES `linapahe` (`emprcodi`, `codmcodi`, `pahenume`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Pagos - Detalle';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linapade_audit_insert` BEFORE INSERT ON `linapade` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linapade_audit_update` BEFORE UPDATE ON `linapade` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linapahe`
--

DROP TABLE IF EXISTS `linapahe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linapahe` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `codmcodi` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Movimiento',
  `pahenume` int NOT NULL DEFAULT '0' COMMENT 'Numero de Comprobante',
  `pahefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Comprobante',
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Proveedor',
  `pahetota` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Total Comprobante',
  `paheefec` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Pagado en Efectivo',
  `pahebanc` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Pagado con Transferencia ó Depósito',
  `paheobse` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Observaciones',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`pahenume`,`codmcodi`),
  KEY `idx_pahe_pade` (`emprcodi`,`codmcodi`,`pahenume`),
  KEY `fk_pahe_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_pahe_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Pagos - Cabecera';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linapahe_audit_insert` BEFORE INSERT ON `linapahe` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linapahe_audit_update` BEFORE UPDATE ON `linapahe` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linaprog`
--

DROP TABLE IF EXISTS `linaprog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linaprog` (
  `progcodi` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Programa',
  `progcall` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Tipo de Miembro',
  `progdesc` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripcion',
  `progowne` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Programa Particular de Este Owner',
  `progexsu` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Si Puede Ejecutarse Desde SUCU#01',
  `progexre` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Si Puede Ejecutarse Remotamente',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`progcodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Programas del Sistema';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaprog_audit_insert` BEFORE INSERT ON `linaprog` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaprog_insert` AFTER INSERT ON `linaprog` FOR EACH ROW BEGIN CALL sp_sync_linasafe(); END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaprog_audit_update` BEFORE UPDATE ON `linaprog` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaprog_update` AFTER UPDATE ON `linaprog` FOR EACH ROW BEGIN
                   IF OLD.progcall <> NEW.progcall THEN
                       CALL sp_sync_linasafe();
                   END IF;
               END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaprog_delete` AFTER DELETE ON `linaprog` FOR EACH ROW BEGIN CALL sp_sync_linasafe(); END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linaprov`
--

DROP TABLE IF EXISTS `linaprov`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linaprov` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'Codigo de Proveedor',
  `provname` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Nombre',
  `provsala` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'Saldo Anterior',
  `provfesa` date NOT NULL DEFAULT '1900-01-01' COMMENT 'Fecha Saldo Anterior',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`provcodi`),
  KEY `idx_prov_provcodi` (`provcodi`),
  CONSTRAINT `fk_prov_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Proveedores';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaprov_audit_insert` BEFORE INSERT ON `linaprov` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linaprov_audit_update` BEFORE UPDATE ON `linaprov` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linasafe`
--

DROP TABLE IF EXISTS `linasafe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linasafe` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `usercodi` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `progcodi` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Código de Programa en linaprog',
  `safealta` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Autorizacion para Altas',
  `safebaja` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Autorizacion para Bajas',
  `safemodi` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Autorizacion para Modificaciones',
  `safecons` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Autorizacion para Consultas',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`usercodi`,`progcodi`),
  KEY `fk_safe_progcodi` (`progcodi`),
  CONSTRAINT `fk_safe_progcodi` FOREIGN KEY (`progcodi`) REFERENCES `linaprog` (`progcodi`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_safe_user` FOREIGN KEY (`emprcodi`, `usercodi`) REFERENCES `linauser` (`emprcodi`, `usercodi`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Permisos de Usuarios';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linasafe_audit_insert` BEFORE INSERT ON `linasafe` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linasafe_audit_update` BEFORE UPDATE ON `linasafe` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `linastrs`
--

DROP TABLE IF EXISTS `linastrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linastrs` (
  `strstable` char(32) NOT NULL DEFAULT '',
  `strsordinal` tinyint NOT NULL DEFAULT '0',
  `strsfield` char(32) DEFAULT '',
  `strstype` char(16) DEFAULT 'C',
  `strslen` tinyint DEFAULT '10',
  `strsdec` tinyint DEFAULT '0',
  `strscolkey` char(3) DEFAULT '',
  `strscomment` varchar(45) DEFAULT '',
  `strsdefault` varchar(45) DEFAULT '',
  `strsboundlow` varchar(45) DEFAULT '',
  `strsboundupper` varchar(45) DEFAULT '',
  `strsuppercased` tinyint DEFAULT '0',
  PRIMARY KEY (`strstable`,`strsordinal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linatabl`
--

DROP TABLE IF EXISTS `linatabl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linatabl` (
  `tablcodi` char(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Codigo de Tabla (Alias)',
  `tabltipo` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Tipo de Tabla [S]istema o [E]Mpresa',
  `tabldesc` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Descripcion',
  PRIMARY KEY (`tablcodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tablas del Sistema';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linauser`
--

DROP TABLE IF EXISTS `linauser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linauser` (
  `emprcodi` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código de Empresa',
  `usercodi` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `username` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Nombre',
  `userpass` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Password SHA2-256',
  `userremo` int NOT NULL DEFAULT '0' COMMENT 'Si Es Usuario Remoto',
  `user` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`usercodi`),
  KEY `idx_safe_usercodi` (`usercodi`),
  CONSTRAINT `fk_user_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Usuarios del Sistema';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linauser_audit_insert` BEFORE INSERT ON `linauser` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'I';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_linauser_hash_bi` BEFORE INSERT ON `linauser` FOR EACH ROW BEGIN
        IF NEW.userpass IS NOT NULL
           AND NEW.userpass <> ''
           AND NEW.userpass NOT REGEXP '^[0-9A-Fa-f]{64}$'
        THEN
            SET NEW.userpass = UPPER(SHA2(NEW.userpass, 256));
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linauser_audit_update` BEFORE UPDATE ON `linauser` FOR EACH ROW BEGIN
                    SET NEW.user = IFNULL(@lina_user, 'SYSTEM');
                    SET NEW.date = DATE_FORMAT(NOW(), '%Y%m%d');
                    SET NEW.time = DATE_FORMAT(NOW(), '%H:%i:%s');
                    SET NEW.oper = 'U';
                    SET NEW.prog = IFNULL(@lina_prog, 'UNKNOWN');
                    SET NEW.wstn = '00';
                    SET NEW.nume = 0;
                END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_linauser_hash_bu` BEFORE UPDATE ON `linauser` FOR EACH ROW BEGIN
        IF NEW.userpass IS NOT NULL
           AND NEW.userpass <> ''
           AND NEW.userpass <> OLD.userpass
           AND NEW.userpass NOT REGEXP '^[0-9A-Fa-f]{64}$'
        THEN
            SET NEW.userpass = UPPER(SHA2(NEW.userpass, 256));
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`lina`@`%`*/ /*!50003 TRIGGER `tr_linauser_delete` AFTER DELETE ON `linauser` FOR EACH ROW BEGIN CALL sp_sync_linasafe(); END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping events for database 'lina'
--

--
-- Dumping routines for database 'lina'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_calc_exis` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calc_exis`(p_articodi CHAR(9), p_fecha_hasta DATE) RETURNS int
    READS SQL DATA
BEGIN
    DECLARE v_exan     INT DEFAULT NULL;
    DECLARE v_entradas INT DEFAULT 0;
    DECLARE v_salidas  INT DEFAULT 0;

    SELECT artiexan
      INTO v_exan
      FROM linaarti
     WHERE articodi = p_articodi;

    IF v_exan IS NULL THEN
        RETURN -1;
    END IF;

    SELECT COALESCE(SUM(fcdecant), 0)
      INTO v_entradas
      FROM linafcde
     WHERE articodi = p_articodi
       AND fchefech <= p_fecha_hasta;

    SELECT COALESCE(SUM(fvdecant), 0)
      INTO v_salidas
      FROM linafvde
     WHERE articodi = p_articodi
       AND fvhefech <= p_fecha_hasta;

    RETURN v_exan + v_entradas - v_salidas;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_clie_sald` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_clie_sald`(
    p_cliecodi INT,
    p_fecha_hasta DATE
) RETURNS decimal(10,2)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_sala  DECIMAL DEFAULT NULL;
    DECLARE ret_val DECIMAL;

    -- 1. Obtener saldo inicial
    SELECT cliesala
      INTO v_sala
      FROM linaclie
     WHERE cliecodi = p_cliecodi;

    -- 2. Validación y Cálculo
    IF v_sala IS NULL THEN
        SET ret_val = null;
    ELSE
        SELECT COALESCE(SUM(ctcldebe-ctclhabe)+v_sala, 0)
          INTO ret_val
          FROM linactcl
         WHERE cliecodi = p_cliecodi
           AND ctclfech <= p_fecha_hasta;
    END IF;
    RETURN ret_val;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_prov_sald` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_prov_sald`(
    p_provcodi INT,
    p_fecha_hasta DATE
) RETURNS decimal(10,2)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_sala  DECIMAL DEFAULT NULL;
    DECLARE ret_val DECIMAL;

    -- 1. Obtener saldo inicial
    SELECT provsala
      INTO v_sala
      FROM linaprov
     WHERE provcodi = p_provcodi;

    -- 2. Validación y Cálculo
    IF v_sala IS NULL THEN
        SET ret_val = null;
    ELSE
    
        -- SELECT COALESCE(SUM(ctprdebe-ctprhabe)+v_sala, 0)
        SELECT SUM(ctprdebe-ctprhabe)
          INTO ret_val
          FROM linactpr
         WHERE provcodi = p_provcodi
           AND ctprfech <= p_fecha_hasta;
    END IF;
    set ret_val=ret_val+v_sala;
    RETURN ret_val;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `@_Fill_LinaStrs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `@_Fill_LinaStrs`()
BEGIN
    -- 1. Vaciar la tabla (Equivalente a TRUNCATE)
    -- Nota: TRUNCATE en MySQL causa un commit implícito, 
    -- por lo que no se puede revertir con ROLLBACK.
    TRUNCATE TABLE linastrs;

    -- 2. Insertar los nuevos datos
    -- En MySQL consultamos 'information_schema' en lugar de 'sys.tables'
    INSERT INTO linastrs (
        strstable,
        strsordinal,
        strsfield,
        strstype,
        strslen,
        strsdec,
        strscolkey,
        strscomment,
        strsdefault
    )
    SELECT 
        TABLE_NAME, 
        ORDINAL_POSITION,
        COLUMN_NAME, 
        DATA_TYPE, 
        COALESCE(CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, 0),
        COALESCE(NUMERIC_SCALE, 0),
        COLUMN_KEY,
        COALESCE(COLUMN_COMMENT, ''), -- Evita nulos en comentarios
        COALESCE(COLUMN_DEFAULT, '')  -- <--- Cambio solicitado: Si es NULL, inserta ''
    FROM information_schema.columns
    WHERE TABLE_SCHEMA = DATABASE(); -- Solo la base de datos actual

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `@_List_Columns` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `@_List_Columns`()
BEGIN
	select table_name,
    ordinal_position,
    column_name, 
    column_default,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    column_key, 
    column_comment
from information_schema.columns 
where table_schema= database()
order by table_name, ordinal_position;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `@_List_Foreign_keys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `@_List_Foreign_keys`()
BEGIN
select DISTINCT `k`.`CONSTRAINT_NAME` AS `Constraint_Name`,
`k`.`TABLE_NAME` AS `Table_Name`,
`k`.`COLUMN_NAME` AS `Column_Name`,
`k`.`ORDINAL_POSITION` AS `Ordinal_Position`,
`k`.`REFERENCED_TABLE_NAME` AS `Referenced_Table_Name`,
`k`.`REFERENCED_COLUMN_NAME` AS `Referenced_Column_Name`,
`r`.`UPDATE_RULE` AS `Update_Rule`,
`r`.`DELETE_RULE` AS `Delete_Rule`,
`k`.`CONSTRAINT_SCHEMA`
from (`information_schema`.`key_column_usage` `k` 
join `information_schema`.`referential_constraints` `r`) 
where (
(`k`.`CONSTRAINT_SCHEMA` = database()) 
and (`k`.`CONSTRAINT_NAME` <> 'primary') 
and (`k`.`CONSTRAINT_NAME` = `r`.`CONSTRAINT_NAME`))
order by table_name,referenced_table_name,constraint_name;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `@_List_Functions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `@_List_Functions`()
BEGIN
	SELECT 
		ROUTINE_NAME,
		ROUTINE_TYPE,
		DTD_IDENTIFIER,
		ROUTINE_DEFINITION,
		IS_DETERMINISTIC,
		SQL_DATA_ACCESS,
		SECURITY_TYPE,
		CREATED,
		LAST_ALTERED,
		DEFINER
	FROM information_schema.routines
	WHERE ROUTINE_SCHEMA = database() AND ROUTINE_TYPE = 'FUNCTION'
	ORDER BY ROUTINE_NAME;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `@_List_Indexes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `@_List_Indexes`()
BEGIN
SELECT 
    TABLE_NAME AS 'Tabla',
    INDEX_NAME AS 'Nombre del Índice',
    COLUMN_NAME AS 'Columna',
    SEQ_IN_INDEX AS 'Posición en Índice',
    IF(NON_UNIQUE = 0, 'SÍ', 'NO') AS 'Es Único',
    IF(INDEX_NAME = 'PRIMARY', 'SÍ', 'NO') AS 'Es Clave Primaria',
    INDEX_TYPE AS 'Tipo de Índice',
    CARDINALITY AS 'Cardinalidad (Est.)'
FROM 
    information_schema.statistics
WHERE 
    TABLE_SCHEMA = database()
ORDER BY 
    TABLE_NAME, 
    INDEX_NAME, 
    SEQ_IN_INDEX;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `@_List_Procedures` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `@_List_Procedures`()
BEGIN
	SELECT 
		ROUTINE_NAME,
		ROUTINE_TYPE,
		DTD_IDENTIFIER,
		ROUTINE_DEFINITION,
		IS_DETERMINISTIC,
		SQL_DATA_ACCESS,
		SECURITY_TYPE,
		CREATED,
		LAST_ALTERED,
		DEFINER
	FROM information_schema.routines
	WHERE ROUTINE_SCHEMA = database() AND ROUTINE_TYPE = 'PROCEDURE'
	ORDER BY ROUTINE_NAME;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `@_List_Tables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `@_List_Tables`()
BEGIN
	Select 
    table_name,
    table_comment 
    from information_schema.TABLES 
    where table_schema=database() and table_type='BASE TABLE';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `@_List_Triggers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `@_List_Triggers`()
BEGIN
	SELECT 
		TRIGGER_NAME,
		EVENT_OBJECT_TABLE,
		ACTION_TIMING,
		EVENT_MANIPULATION,
		ACTION_STATEMENT,
		CREATED,
		SQL_MODE,
		DEFINER
	FROM information_schema.triggers
	WHERE TRIGGER_SCHEMA = database()
	ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_calc_exist` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_calc_exist`(
    IN  p_articodi    CHAR(9),
    IN  p_fecha_hasta DATE,
    OUT ret_val       INT
)
BEGIN
    DECLARE v_exan     INT DEFAULT NULL;
    DECLARE v_entradas INT DEFAULT 0;
    DECLARE v_salidas  INT DEFAULT 0;

    SELECT artiexan
      INTO v_exan
      FROM linaarti
     WHERE articodi = p_articodi;

    IF v_exan IS NULL THEN
        SET ret_val = -1;
    ELSE
        SELECT COALESCE(SUM(fcdecant), 0)
          INTO v_entradas
          FROM linafcde
         WHERE articodi = p_articodi
           AND fchefech <= p_fecha_hasta;

        SELECT COALESCE(SUM(fvdecant), 0)
          INTO v_salidas
          FROM linafvde
         WHERE articodi = p_articodi
           AND fvhefech <= p_fecha_hasta;

        SET ret_val = v_exan + v_entradas - v_salidas;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_copy_user_rights` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lina`@`%` PROCEDURE `sp_copy_user_rights`(
    IN p_source_emprcodi VARCHAR(8)  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_source_usercodi VARCHAR(64) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_target_emprcodi VARCHAR(8)  CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_target_usercodi VARCHAR(64) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
)
    MODIFIES SQL DATA
BEGIN
    DECLARE v_source_exists INT DEFAULT 0;
    DECLARE v_target_exists INT DEFAULT 0;

    SELECT COUNT(*)
      INTO v_source_exists
      FROM linauser
     WHERE emprcodi = p_source_emprcodi
       AND usercodi = p_source_usercodi;

    IF v_source_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'sp_copy_user_rights: usuario origen no existe.';
    END IF;


    SELECT COUNT(*)
      INTO v_target_exists
      FROM linauser
     WHERE emprcodi = p_target_emprcodi
       AND usercodi = p_target_usercodi;

    IF v_target_exists = 0 THEN
          -- Crear usuario destino copiando todos los datos del usuario origen, cambiando emprcodi y usercodi
          INSERT INTO linauser (
              emprcodi, usercodi, username, userpass, userremo, user, date, time, oper, prog, wstn, nume
          )
          SELECT
              p_target_emprcodi, p_target_usercodi, username, userpass, userremo, user, date, time, oper, prog, wstn, nume
          FROM linauser
          WHERE emprcodi = p_source_emprcodi AND usercodi = p_source_usercodi;
    END IF;

    -- Asegura que linasafe tenga combinaciones vigentes antes de copiar permisos.
    CALL sp_sync_linasafe();

    UPDATE linasafe t
    JOIN linasafe s
      ON s.emprcodi = p_source_emprcodi
     AND s.usercodi = p_source_usercodi
     AND s.progcodi = t.progcodi
       SET t.safealta = s.safealta,
           t.safebaja = s.safebaja,
           t.safemodi = s.safemodi,
           t.safecons = s.safecons,
           t.user = 'SYSTEM',
           t.date = DATE_FORMAT(NOW(), '%Y%m%d'),
           t.time = DATE_FORMAT(NOW(), '%H:%i:%s'),
           t.oper = 'U',
           t.prog = 'SP_COPY_RIGHTS',
           t.wstn = '00',
           t.nume = 0
     WHERE t.emprcodi = p_target_emprcodi
       AND t.usercodi = p_target_usercodi;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_count_hijos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_count_hijos`(
    IN  p_schema       VARCHAR(64)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN  p_tabla_padre  VARCHAR(64)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN  p_val1         VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN  p_val2         VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN  p_val3         VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN  p_val4         VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    OUT out_total_hijos INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_constraint_name VARCHAR(64);
    DECLARE v_tabla_hija      VARCHAR(64);
    DECLARE v_acumulado       INT DEFAULT 0;

    -- Cursor para encontrar las FKs
    DECLARE cur_fks CURSOR FOR 
        SELECT DISTINCT CONSTRAINT_NAME, TABLE_NAME
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE REFERENCED_TABLE_SCHEMA = p_schema
          AND REFERENCED_TABLE_NAME = p_tabla_padre;
          
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET v_acumulado = 0;

    OPEN cur_fks;

    read_loop: LOOP
        FETCH cur_fks INTO v_constraint_name, v_tabla_hija;
        IF done THEN 
            LEAVE read_loop; 
        END IF;

        SET @where_clause = '';
        
        -- Construcción del WHERE dinámico con COLLATE explícito
        SELECT GROUP_CONCAT(
            CONCAT('`', COLUMN_NAME, '` = ', 
                CASE ORDINAL_POSITION 
                    WHEN 1 THEN CONCAT(QUOTE(p_val1), ' COLLATE utf8mb4_unicode_ci')
                    WHEN 2 THEN CONCAT(QUOTE(p_val2), ' COLLATE utf8mb4_unicode_ci')
                    WHEN 3 THEN CONCAT(QUOTE(p_val3), ' COLLATE utf8mb4_unicode_ci')
                    WHEN 4 THEN CONCAT(QUOTE(p_val4), ' COLLATE utf8mb4_unicode_ci')
                END
            ) SEPARATOR ' AND '
        ) INTO @where_clause
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE CONSTRAINT_NAME = v_constraint_name 
          AND TABLE_SCHEMA = p_schema;

        -- Ejecución dinámica con backticks para seguridad de nombres
        SET @sql_text = CONCAT('SELECT COUNT(*) INTO @v_count_temp FROM `', p_schema, '`.`', v_tabla_hija, '` WHERE ', @where_clause);
        
        PREPARE stmt FROM @sql_text;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET v_acumulado = v_acumulado + IFNULL(@v_count_temp, 0);

    END LOOP;
    
    CLOSE cur_fks;

    -- Asignación final al parámetro OUT
    SET out_total_hijos = v_acumulado;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_InsertRow` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_InsertRow`(
    IN p_schema_name VARCHAR(64),
    IN p_sql_insert TEXT
)
BloquePrincipal: BEGIN
    DECLARE v_status INT DEFAULT 0;
    DECLARE v_msg TEXT DEFAULT 'OK';
    DECLARE v_db_error_msg TEXT DEFAULT '';
    DECLARE v_fk_name VARCHAR(64);
    DECLARE v_parent_table VARCHAR(64);

    -- 1. Manejador para DUPLICADOS (Status 1)
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
        SET v_status = 1;
        SET v_msg = 'Error: Registro ya existe en la tabla destino (PK Duplicada)';
    END;

    -- 2. Manejador para LLAVES FORÁNEAS (Status 2)
    DECLARE CONTINUE HANDLER FOR 1452
    BEGIN
        -- Capturamos el mensaje original del sistema
        GET DIAGNOSTICS CONDITION 1 v_db_error_msg = MESSAGE_TEXT;
        
        -- Extraemos el nombre de la FK del mensaje (ej: `fk_ventas_clientes`)
        SET v_fk_name = SUBSTRING_INDEX(SUBSTRING_INDEX(v_db_error_msg, 'CONSTRAINT `', -1), '`', 1);
        
        -- Buscamos a qué tabla pertenece esa FK en el diccionario de datos
        SELECT REFERENCED_TABLE_NAME INTO v_parent_table
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE CONSTRAINT_SCHEMA = p_schema_name 
          AND CONSTRAINT_NAME = v_fk_name
        LIMIT 1;

        SET v_status = 2;
        SET v_msg = CONCAT('Error FK: No existe el registro relacionado en la tabla padre: ', 
                           COALESCE(v_parent_table, v_fk_name), '');
    END;

    -- 3. Manejador para ERRORES GENERALES (Status 3)
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        IF v_status = 0 THEN
            GET DIAGNOSTICS CONDITION 1 v_db_error_msg = MESSAGE_TEXT;
            SET v_status = 3;
            SET v_msg = CONCAT('Error Sintaxis/Sistema: ', v_db_error_msg);
        END IF;
    END;

    -- EJECUCIÓN DEL SQL DINÁMICO
    SET @sql_query = p_sql_insert;
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- RESULTADO FINAL
    SELECT v_status AS status, v_msg AS mensaje;

END BloquePrincipal ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rescta_clies` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rescta_clies`(
    IN p_empr       CHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_fecini     DATE,
    IN p_fecfin     DATE,
    IN p_codiin     INT,
    IN p_codifi     INT,
    IN p_saldo_cero TINYINT
)
BEGIN
    -- Fecha inferior efectiva para MV: si p_fecini es NULL usamos la menor fecha posible.
    -- (linactcl no contiene registros anteriores a cliefesa, así que el riesgo de
    --  doble-cómputo con cliesala es mínimo, pero la lógica es correcta de todas formas.)

    -- ── Fila SA por cada cliente elegible ─────────────────────
    SELECT
        c.cliecodi,
        c.cliename,
        'SA'  AS linea_tipo,
        CASE WHEN p_fecini IS NOT NULL
             THEN DATE_SUB(p_fecini, INTERVAL 1 DAY)
             ELSE c.cliefesa
        END   AS ctclfech,
        'SALDO ANTERIOR' AS concepto,
        0.00  AS ctcldebe,
        0.00  AS ctclhabe,
        0     AS sort_key,
        -- saldo_ant: base + compactación de movimientos previos a p_fecini
        COALESCE(c.cliesala, 0) + CASE
            WHEN p_fecini IS NOT NULL
            THEN COALESCE((
                     SELECT SUM(t2.ctcldebe - t2.ctclhabe)
                     FROM   linactcl t2
                     WHERE  t2.emprcodi = p_empr
                       AND  t2.cliecodi = c.cliecodi
                       AND  t2.ctclfech < p_fecini
                 ), 0)
            ELSE 0
        END   AS saldo_ant

    FROM linaclie c
    WHERE c.emprcodi = p_empr
      AND c.cliecodi BETWEEN p_codiin AND p_codifi
      -- saldo final != 0  (saldo final = cliesala + TODOS los movs hasta p_fecfin)
      AND (
          p_saldo_cero = 1
          OR ABS(
              COALESCE(c.cliesala, 0) + COALESCE((
                  SELECT SUM(t4.ctcldebe - t4.ctclhabe)
                  FROM   linactcl t4
                  WHERE  t4.emprcodi = p_empr
                    AND  t4.cliecodi = c.cliecodi
                    AND  t4.ctclfech <= p_fecfin
              ), 0)
          ) > 0.005
      )
      -- tiene saldo inicial != 0 O movimientos en el rango de salida
      AND (
          ABS(COALESCE(c.cliesala, 0) + CASE
              WHEN p_fecini IS NOT NULL
              THEN COALESCE((
                       SELECT SUM(t3.ctcldebe - t3.ctclhabe)
                       FROM   linactcl t3
                       WHERE  t3.emprcodi = p_empr
                         AND  t3.cliecodi = c.cliecodi
                         AND  t3.ctclfech < p_fecini
                   ), 0)
              ELSE 0
          END) > 0.005
          OR EXISTS (
              SELECT 1 FROM linactcl te
              WHERE  te.emprcodi = p_empr
                AND  te.cliecodi = c.cliecodi
                AND  te.ctclfech >= CASE WHEN p_fecini IS NULL THEN '1000-01-01' ELSE p_fecini END
                AND  te.ctclfech <= p_fecfin
          )
      )

    UNION ALL

    -- ── Filas MV: movimientos dentro del rango de salida ──────
    SELECT
        c2.cliecodi,
        c2.cliename,
        'MV'  AS linea_tipo,
        t.ctclfech,
        CONCAT(t.codmcodi, ' ', LPAD(t.ctclnumc, 6, '0')) AS concepto,
        COALESCE(t.ctcldebe, 0) AS ctcldebe,
        COALESCE(t.ctclhabe, 0) AS ctclhabe,
        t.ctclid AS sort_key,
        0.00 AS saldo_ant

    FROM linactcl t
    JOIN linaclie c2
      ON c2.emprcodi = t.emprcodi
     AND c2.cliecodi = t.cliecodi
    WHERE t.emprcodi = p_empr
      AND t.cliecodi BETWEEN p_codiin AND p_codifi
      AND t.ctclfech >= CASE WHEN p_fecini IS NULL THEN '1000-01-01' ELSE p_fecini END
      AND t.ctclfech <= p_fecfin
      -- excluir cliente si su saldo final es cero y p_saldo_cero=0
      AND (
          p_saldo_cero = 1
          OR ABS(
              COALESCE(c2.cliesala, 0) + COALESCE((
                  SELECT SUM(t5.ctcldebe - t5.ctclhabe)
                  FROM   linactcl t5
                  WHERE  t5.emprcodi = p_empr
                    AND  t5.cliecodi = t.cliecodi
                    AND  t5.ctclfech <= p_fecfin
              ), 0)
          ) > 0.005
      )

    ORDER BY
        cliecodi,
        CASE linea_tipo WHEN 'SA' THEN 0 ELSE 1 END,
        ctclfech,
        sort_key;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rescta_provs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rescta_provs`(
    IN p_empr       CHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_fecini     DATE,
    IN p_fecfin     DATE,
    IN p_codiin     INT,
    IN p_codifi     INT,
    IN p_saldo_cero TINYINT
)
BEGIN

    -- ── Fila SA por cada proveedor elegible ───────────────────
    SELECT
        p.provcodi,
        p.provname,
        'SA'  AS linea_tipo,
        CASE WHEN p_fecini IS NOT NULL
             THEN DATE_SUB(p_fecini, INTERVAL 1 DAY)
             ELSE p.provfesa
        END   AS ctprfech,
        'SALDO ANTERIOR' AS concepto,
        0.00  AS ctprdebe,
        0.00  AS ctprhabe,
        0     AS sort_key,
        -- saldo_ant: base + compactación de movimientos previos a p_fecini
        COALESCE(p.provsala, 0) + CASE
            WHEN p_fecini IS NOT NULL
            THEN COALESCE((
                     SELECT SUM(t2.ctprhabe - t2.ctprdebe)
                     FROM   linactpr t2
                     WHERE  t2.emprcodi = p_empr
                       AND  t2.provcodi = p.provcodi
                       AND  t2.ctprfech < p_fecini
                 ), 0)
            ELSE 0
        END   AS saldo_ant

    FROM linaprov p
    WHERE p.emprcodi = p_empr
      AND p.provcodi BETWEEN p_codiin AND p_codifi
      -- saldo final != 0 (saldo final = provsala + TODOS los movs hasta p_fecfin)
      AND (
          p_saldo_cero = 1
          OR ABS(
              COALESCE(p.provsala, 0) + COALESCE((
                  SELECT SUM(t4.ctprhabe - t4.ctprdebe)
                  FROM   linactpr t4
                  WHERE  t4.emprcodi = p_empr
                    AND  t4.provcodi = p.provcodi
                    AND  t4.ctprfech <= p_fecfin
              ), 0)
          ) > 0.005
      )
      -- tiene saldo inicial != 0 O movimientos en el rango de salida
      AND (
          ABS(COALESCE(p.provsala, 0) + CASE
              WHEN p_fecini IS NOT NULL
              THEN COALESCE((
                       SELECT SUM(t3.ctprhabe - t3.ctprdebe)
                       FROM   linactpr t3
                       WHERE  t3.emprcodi = p_empr
                         AND  t3.provcodi = p.provcodi
                         AND  t3.ctprfech < p_fecini
                   ), 0)
              ELSE 0
          END) > 0.005
          OR EXISTS (
              SELECT 1 FROM linactpr te
              WHERE  te.emprcodi = p_empr
                AND  te.provcodi = p.provcodi
                AND  te.ctprfech >= CASE WHEN p_fecini IS NULL THEN '1000-01-01' ELSE p_fecini END
                AND  te.ctprfech <= p_fecfin
          )
      )

    UNION ALL

    -- ── Filas MV: movimientos dentro del rango de salida ──────
    SELECT
        p2.provcodi,
        p2.provname,
        'MV'  AS linea_tipo,
        t.ctprfech,
        CONCAT(t.codmcodi, ' ', LPAD(t.ctprnumc, 6, '0')) AS concepto,
        COALESCE(t.ctprdebe, 0) AS ctprdebe,
        COALESCE(t.ctprhabe, 0) AS ctprhabe,
        t.ctprid AS sort_key,
        0.00 AS saldo_ant

    FROM linactpr t
    JOIN linaprov p2
      ON p2.emprcodi = t.emprcodi
     AND p2.provcodi = t.provcodi
    WHERE t.emprcodi = p_empr
      AND t.provcodi BETWEEN p_codiin AND p_codifi
      AND t.ctprfech >= CASE WHEN p_fecini IS NULL THEN '1000-01-01' ELSE p_fecini END
      AND t.ctprfech <= p_fecfin
      -- excluir proveedor si su saldo final es cero y p_saldo_cero=0
      AND (
          p_saldo_cero = 1
          OR ABS(
              COALESCE(p2.provsala, 0) + COALESCE((
                  SELECT SUM(t5.ctprhabe - t5.ctprdebe)
                  FROM   linactpr t5
                  WHERE  t5.emprcodi = p_empr
                    AND  t5.provcodi = t.provcodi
                    AND  t5.ctprfech <= p_fecfin
              ), 0)
          ) > 0.005
      )

    ORDER BY
        provcodi,
        CASE linea_tipo WHEN 'SA' THEN 0 ELSE 1 END,
        ctprfech,
        sort_key;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_saldo_clies` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_saldo_clies`(
    IN p_empr   CHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_codiin INT,
    IN p_codifi INT,
    IN p_fecfin DATE
)
BEGIN
    SELECT
        c.cliecodi,
        c.cliename,
        COALESCE(c.cliesala, 0) + COALESCE((
            SELECT SUM(t.ctcldebe - t.ctclhabe)
            FROM   linactcl t
            WHERE  t.emprcodi = p_empr
              AND  t.cliecodi = c.cliecodi
              AND  t.ctclfech <= p_fecfin
        ), 0) AS saldo

    FROM  linaclie c
    WHERE c.emprcodi = p_empr
      AND c.cliecodi BETWEEN p_codiin AND p_codifi

    ORDER BY c.cliecodi;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_saldo_provs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_saldo_provs`(
    IN p_empr   CHAR(2) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci,
    IN p_codiin INT,
    IN p_codifi INT,
    IN p_fecfin DATE
)
BEGIN
    SELECT
        p.provcodi,
        p.provname,
        COALESCE(p.provsala, 0) + COALESCE((
            SELECT SUM(t.ctprhabe - t.ctprdebe)
            FROM   linactpr t
            WHERE  t.emprcodi = p_empr
              AND  t.provcodi = p.provcodi
              AND  t.ctprfech <= p_fecfin
        ), 0) AS saldo

    FROM  linaprov p
    WHERE p.emprcodi = p_empr
      AND p.provcodi BETWEEN p_codiin AND p_codifi

    ORDER BY p.provcodi;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_sync_linasafe` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lina`@`%` PROCEDURE `sp_sync_linasafe`()
    MODIFIES SQL DATA
BEGIN
    -- 1. Insertar registros faltantes en linasafe para cada combinación de usuario y programa
    --    Solo para programas que tengan un ejecutable definido (progcall no vacío)
    INSERT INTO linasafe (
        emprcodi, usercodi, progcodi,
        safealta, safebaja, safemodi, safecons,
        user, date, time, oper, prog, wstn, nume
    )
    SELECT
        u.emprcodi, u.usercodi, p.progcodi,
        '', '', '', '',
        'SYSTEM',
        DATE_FORMAT(NOW(), '%Y%m%d'),
        DATE_FORMAT(NOW(), '%H:%i:%s'),
        'I', 'SP_SYNC', '00', 0
    FROM linauser u
    CROSS JOIN linaprog p
    LEFT JOIN linasafe s ON u.emprcodi = s.emprcodi AND u.usercodi = s.usercodi AND p.progcodi = s.progcodi
    WHERE IFNULL(s.usercodi, '') = ''
      AND TRIM(IFNULL(p.progcall, '')) <> '';

    -- 2. Eliminar registros de linasafe que:
    --    a) No tienen un usuario o programa válido (Join fallido -> '')
    --    b) El programa tiene un progcall vacío o solo espacios (nodos de menú sin acción)
    DELETE s FROM linasafe s
    LEFT JOIN linauser u ON s.emprcodi = u.emprcodi AND s.usercodi = u.usercodi
    LEFT JOIN linaprog p ON s.progcodi = p.progcodi
    WHERE IFNULL(u.usercodi, '') = ''
       OR IFNULL(p.progcodi, '') = ''
       OR TRIM(IFNULL(p.progcall, '')) = '';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-25 21:31:01
