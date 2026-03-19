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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `articodi` char(9) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO ARTICULO TIPO SP-9999',
  `artrcodi` char(9) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'RUBRO DEL ARTICULO',
  `artidesc` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION',
  `artiexan` int NOT NULL DEFAULT '0' COMMENT 'EXISTENCIA ANTERIOR CANTIDAD',
  `artiexfe` date NOT NULL DEFAULT '1900-01-01' COMMENT 'EXISTENCIA ANTERIOR FECHA',
  `artipmpe` int NOT NULL DEFAULT '0' COMMENT 'PUNTO MINIMO DE PEDIDO',
  `artiucco` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'COSTO ULTIMA COMPRA',
  `artiucfe` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA ULTIMA COMPRA',
  `artiucca` int NOT NULL DEFAULT '0' COMMENT 'CANTIDAD ULTIMA COMPRA',
  `artiprec` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'PRECIO DE VENTA',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`articodi`),
  KEY `idx_arti_articodi` (`articodi`),
  KEY `fk_arti_artr` (`emprcodi`,`artrcodi`),
  CONSTRAINT `fk_arti_artr` FOREIGN KEY (`emprcodi`, `artrcodi`) REFERENCES `linaartr` (`emprcodi`, `artrcodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_arti_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linaartr`
--

DROP TABLE IF EXISTS `linaartr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linaartr` (
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `artrcodi` char(9) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE RUBRO',
  `artrdesc` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION',
  `artrsalp` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'SALTO DE PAGINA (S/N)',
  `artrsala` int NOT NULL DEFAULT '0' COMMENT 'RENGLONES ANTES',
  `artrsald` int NOT NULL DEFAULT '0' COMMENT 'RENGLONES DESPUES',
  `artrsubr` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CARACTER DE SUBRAYADO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`artrcodi`),
  KEY `idx_artr_emprcodi` (`emprcodi`),
  KEY `idx_artr_artrcodi` (`artrcodi`),
  CONSTRAINT `fk_artr_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `bancid` int NOT NULL AUTO_INCREMENT,
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'EMPRESA',
  `cliecodi` int NOT NULL DEFAULT '0',
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE CUENTA',
  `bancfech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA',
  `bancnumc` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE ORIGEN',
  `bancconc` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CONCEPTO',
  `bancdebe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'IMPORTE DEBITO',
  `banchabe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'IMPORTE CREDITO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`bancid`),
  KEY `fk_banc_clie` (`emprcodi`,`cliecodi`),
  KEY `fk_banc_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_banc_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_banc_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=143 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `cajaid` int NOT NULL AUTO_INCREMENT,
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'EMPRESA',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE CUENTA',
  `provcodi` int NOT NULL,
  `cajafech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA',
  `cajanumc` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE ORIGEN',
  `cajaconc` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CONCEPTO',
  `cajadebe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'IMPORTE DEBITO',
  `cajahabe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'IMPORTE CREDITO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`cajaid`),
  KEY `fk_caja_clie` (`emprcodi`,`cliecodi`),
  KEY `fk_caja_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_caja_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_caja_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1288 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'CODIGO DE CLIENTE',
  `cliename` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'NOMBRE',
  `cliesala` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'SALDO ANTERIOR',
  `cliefesa` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA SALDO ANTERIOR',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`cliecodi`),
  KEY `idx_clie_cliecodi` (`cliecodi`),
  CONSTRAINT `fk_clie_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `cohenume` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `codereng` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE RENGLON',
  `codedesc` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION CONCEPTO',
  `codeunit` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'UNITARIO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`cohenume`,`codereng`,`emprcodi`,`codmcodi`),
  KEY `fk_code_cohe` (`emprcodi`,`codmcodi`,`cohenume`),
  CONSTRAINT `fk_code_cohe` FOREIGN KEY (`emprcodi`, `codmcodi`, `cohenume`) REFERENCES `linacohe` (`emprcodi`, `codmcodi`, `cohenume`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `codmclpr` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '<c>LIENTE O <P>ROVEEDOR',
  `codmdecr` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '<D>EBITO O <C>REDITO',
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `codmdesc` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION',
  `codmultn` int NOT NULL DEFAULT '0' COMMENT 'ULTIMO NUMERO USADO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`codmclpr`,`codmdecr`,`codmcodi`),
  KEY `idx_codm_codmcodi` (`codmcodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `cohenume` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `cohefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA COMPROBANTE',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'CODIGO DE CUENTA',
  `cohetota` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'TOTAL COMPROBANTE',
  `coheefec` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'COBRADO EN EFECTIVO',
  `cohebanc` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'COBRADO EN TRANSF. O DEPOSITO',
  `coheobse` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'PERSONA QUE PAGO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`codmcodi`,`cohenume`,`emprcodi`),
  KEY `idx_cohe_empr_clie` (`emprcodi`,`cliecodi`) /*!80000 INVISIBLE */,
  KEY `idx_cohe_code` (`emprcodi`,`codmcodi`,`cohenume`),
  CONSTRAINT `fk_cohe_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `ctclid` int NOT NULL AUTO_INCREMENT,
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'CODIGO DE CLIENTE',
  `ctclfech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA MOVIMIENTO',
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `ctclnumc` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `ctcldebe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'IMPORTE AL DEBE',
  `ctclhabe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'IMPORTE AL HABER',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ctclid`),
  KEY `fk_ctcl__clie` (`emprcodi`,`cliecodi`),
  CONSTRAINT `fk_ctcl__clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2534 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'CODIGO DE PROVEEDOR',
  `ctprfech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA MOVIMIENTO',
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `ctprnumc` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `ctprdebe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'IMPORTE AL DEBE',
  `ctprhabe` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'IMPORTE AL HABER',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ctprid`),
  KEY `fk_ctpr_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_ctpr_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=421 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE EMPRESA',
  `emprname` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'RAZON SOCIAL',
  `emprdire` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DIRECCION',
  `emprcodp` char(5) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO POSTAL',
  `emprloca` varchar(34) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'LOCALIDAD',
  `emprtele` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'TELEFONO',
  `emprciva` int NOT NULL DEFAULT '0' COMMENT 'CONDICION FRENTE A IVA',
  `emprcgan` int NOT NULL DEFAULT '0' COMMENT 'CONDICION FRENTE A GANANCIAS',
  `emprcuit` decimal(11,0) NOT NULL DEFAULT '0' COMMENT 'CUIT',
  `emprunid` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'UNIDAD DE TRABAJO',
  `emprnume` int NOT NULL DEFAULT '0' COMMENT 'CONTROL (NAME+DIRE)',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `erroid` int NOT NULL AUTO_INCREMENT,
  `errowstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `errouser` char(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `errodate` date NOT NULL DEFAULT '1900-01-01',
  `errotime` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroempr` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erronume` int NOT NULL DEFAULT '0',
  `erromssg` varchar(78) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `errosour` varchar(78) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroline` int NOT NULL DEFAULT '0',
  `erroprg0` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg1` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg2` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg3` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg4` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg5` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg6` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg7` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg8` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `erroprg9` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`erroid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linafcde`
--

DROP TABLE IF EXISTS `linafcde`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linafcde` (
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `fchenume` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `fcdereng` int NOT NULL DEFAULT '0' COMMENT 'RENGLON DEL COMPROBANTE',
  `fcdefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA MOVIMIENTO PARA CARDEX',
  `articodi` char(9) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE ARTICULO',
  `fcdedesc` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION DE ITEM',
  `fcdecant` int NOT NULL DEFAULT '0' COMMENT 'CANTIDAD',
  `fcdeunit` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'UNITARIO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`fchenume`,`fcdereng`,`codmcodi`),
  KEY `fk_fcde_articodi` (`articodi`),
  KEY `fk_fcde_fche` (`emprcodi`,`codmcodi`,`fchenume`),
  CONSTRAINT `fk_fcde_articodi` FOREIGN KEY (`articodi`) REFERENCES `linaarti` (`articodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_fcde_fche` FOREIGN KEY (`emprcodi`, `codmcodi`, `fchenume`) REFERENCES `linafche` (`emprcodi`, `codmcodi`, `fchenume`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `fchenume` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `fchefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA COMPROBANTE',
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'CODIGO DE CUENTA',
  `fchetota` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'TOTAL COMPROBANTE',
  `fcheobse` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'OBSERVACIONES',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`fchenume`,`emprcodi`,`codmcodi`),
  KEY `idx_fche_fcde` (`emprcodi`,`codmcodi`,`fchenume`),
  KEY `fk_fche_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_fche_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `fvhenume` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `fvdereng` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE RENGLON',
  `fvhefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA MOVIMIENTO PARA CARDEX',
  `articodi` char(9) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE ARTICULO',
  `fvdedesc` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION DEL ITEM',
  `fvdecant` int NOT NULL DEFAULT '0' COMMENT 'CANTIDAD',
  `fvdeunit` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'UNITARIO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`codmcodi`,`fvhenume`,`fvdereng`),
  KEY `idx_fvde_articodi` (`articodi`),
  CONSTRAINT `fk_fvde_articodi` FOREIGN KEY (`articodi`) REFERENCES `linaarti` (`articodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_fvde_fvhe` FOREIGN KEY (`emprcodi`, `codmcodi`, `fvhenume`) REFERENCES `linafvhe` (`emprcodi`, `codmcodi`, `fvhenume`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `fvhenume` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `fvhefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA COMPROBANTE',
  `cliecodi` int NOT NULL DEFAULT '0' COMMENT 'CODIGO DE CUENTA',
  `fvhetota` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'TOTAL COMPROBANTE',
  `fvheobse` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'PERSONA QUE RETIRA',
  `fvhereci` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE RECIBO SIMULTANEO A FACT.',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`fvhenume`,`emprcodi`,`codmcodi`),
  KEY `idx_fvhe_codmcodi` (`codmcodi`),
  KEY `idx_fvhe_fvde` (`emprcodi`,`codmcodi`,`fvhenume`),
  KEY `fk_fvde_clie` (`emprcodi`,`cliecodi`),
  CONSTRAINT `fk_fvde_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_fvhe_codmcodi` FOREIGN KEY (`codmcodi`) REFERENCES `linacodm` (`codmcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `mixtclav` char(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `mixtdato` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`mixtclav`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linapade`
--

DROP TABLE IF EXISTS `linapade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linapade` (
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `pahenume` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `padereng` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE RENGLON',
  `padedesc` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION CONCEPTO',
  `padeunit` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'UNITARIO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`codmcodi`,`pahenume`,`padereng`),
  CONSTRAINT `fk_pade_pahe` FOREIGN KEY (`emprcodi`, `codmcodi`, `pahenume`) REFERENCES `linapahe` (`emprcodi`, `codmcodi`, `pahenume`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codmcodi` char(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE MOVIMIENTO',
  `pahenume` int NOT NULL DEFAULT '0' COMMENT 'NUMERO DE COMPROBANTE',
  `pahefech` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA COMPROBANTE',
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'CODIGO DE CUENTA',
  `pahetota` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'TOTAL COMPROBANTE',
  `paheefec` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'PAGADO EN EFECTIVO',
  `pahebanc` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'PAGADO CON TRANSFERENCIA',
  `paheobse` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'PERSONA QUE RECIBIO EL PAGO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`pahenume`,`codmcodi`),
  KEY `idx_pahe_pade` (`emprcodi`,`codmcodi`,`pahenume`),
  KEY `fk_pahe_prov` (`emprcodi`,`provcodi`),
  CONSTRAINT `fk_pahe_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `progcodi` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE PROGRAMA',
  `progcall` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'TIPO DE MIEMBRO',
  `progdesc` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION',
  `progowne` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'PROGRAMA PARTICULAR DE ESTE OWNER',
  `progexsu` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'SI PUEDE EJECUTARSE DESDE SUCU#01',
  `progexre` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'SI PUEDE EJECUTARSE REMOTAMENTE',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`progcodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provcodi` int NOT NULL DEFAULT '0' COMMENT 'CODIGO DE PROVEEDOR',
  `provname` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'NOMBRE',
  `provsala` decimal(11,2) NOT NULL DEFAULT '0.00' COMMENT 'SALDO ANTERIOR',
  `provfesa` date NOT NULL DEFAULT '1900-01-01' COMMENT 'FECHA SALDO ANTERIOR',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`provcodi`),
  KEY `idx_prov_provcodi` (`provcodi`),
  CONSTRAINT `fk_prov_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usercodi` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `progcodi` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'ID. PROGRAMA',
  `safealta` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'AUTORIZACION PARA ALTAS',
  `safebaja` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'AUTORIZACION PARA BAJAS',
  `safemodi` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'AUTORIZACION PARA MODIFICACIONES',
  `safecons` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'AUTORIZACION PARA CONSULTAS',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`usercodi`,`progcodi`),
  KEY `fk_safe_progcodi` (`progcodi`),
  CONSTRAINT `fk_safe_progcodi` FOREIGN KEY (`progcodi`) REFERENCES `linaprog` (`progcodi`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_safe_user` FOREIGN KEY (`emprcodi`, `usercodi`) REFERENCES `linauser` (`emprcodi`, `usercodi`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
-- Table structure for table `linatabl`
--

DROP TABLE IF EXISTS `linatabl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linatabl` (
  `tablcodi` char(6) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'CODIGO DE TABLA (ALIAS)',
  `tabltipo` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'TIPO DE TABLA [S]ISTEMA O [E]MPRESA',
  `tabldesc` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'DESCRIPCION',
  PRIMARY KEY (`tablcodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `linauser`
--

DROP TABLE IF EXISTS `linauser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `linauser` (
  `emprcodi` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usercodi` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `username` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'NOMBRE',
  `userpass` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'PASSWORD SHA2-256',
  `userremo` int NOT NULL DEFAULT '0' COMMENT 'SI ES USUARIO REMOTO',
  `user` char(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` char(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `oper` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prog` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `wstn` char(2) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `nume` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`emprcodi`,`usercodi`),
  KEY `idx_safe_usercodi` (`usercodi`),
  CONSTRAINT `fk_user_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
/*!50003 DROP PROCEDURE IF EXISTS `ADMIN_show_full_process_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ADMIN_show_full_process_list`()
BEGIN
SHOW FULL PROCESSLIST;
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
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sp_copy_user_rights: usuario destino no existe.';
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

-- Dump completed on 2026-03-16 15:04:18
