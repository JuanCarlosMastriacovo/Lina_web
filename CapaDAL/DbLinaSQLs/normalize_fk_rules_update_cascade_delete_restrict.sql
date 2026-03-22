-- Script generado automaticamente para normalizar FKs en esquema `lina`
-- Regla general: ON UPDATE CASCADE + ON DELETE RESTRICT
-- Excepcion: referencias a linauser y linaprog usan ON DELETE CASCADE
USE `lina`;

ALTER TABLE `linaarti` DROP FOREIGN KEY `fk_arti_artr`;
ALTER TABLE `linaarti` ADD CONSTRAINT `fk_arti_artr` FOREIGN KEY (`emprcodi`, `artrcodi`) REFERENCES `linaartr` (`emprcodi`, `artrcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linaarti` DROP FOREIGN KEY `fk_arti_emprcodi`;
ALTER TABLE `linaarti` ADD CONSTRAINT `fk_arti_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linaartr` DROP FOREIGN KEY `fk_artr_emprcodi`;
ALTER TABLE `linaartr` ADD CONSTRAINT `fk_artr_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linabanc` DROP FOREIGN KEY `fk_banc_clie`;
ALTER TABLE `linabanc` ADD CONSTRAINT `fk_banc_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linabanc` DROP FOREIGN KEY `fk_banc_prov`;
ALTER TABLE `linabanc` ADD CONSTRAINT `fk_banc_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linacaja` DROP FOREIGN KEY `fk_caja_clie`;
ALTER TABLE `linacaja` ADD CONSTRAINT `fk_caja_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linacaja` DROP FOREIGN KEY `fk_caja_prov`;
ALTER TABLE `linacaja` ADD CONSTRAINT `fk_caja_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linaclie` DROP FOREIGN KEY `fk_clie_emprcodi`;
ALTER TABLE `linaclie` ADD CONSTRAINT `fk_clie_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linacode` DROP FOREIGN KEY `fk_code_cohe`;
ALTER TABLE `linacode` ADD CONSTRAINT `fk_code_cohe` FOREIGN KEY (`emprcodi`, `codmcodi`, `cohenume`) REFERENCES `linacohe` (`emprcodi`, `codmcodi`, `cohenume`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linacohe` DROP FOREIGN KEY `fk_cohe_clie`;
ALTER TABLE `linacohe` ADD CONSTRAINT `fk_cohe_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linactcl` DROP FOREIGN KEY `fk_ctcl__clie`;
ALTER TABLE `linactcl` ADD CONSTRAINT `fk_ctcl__clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linactpr` DROP FOREIGN KEY `fk_ctpr_prov`;
ALTER TABLE `linactpr` ADD CONSTRAINT `fk_ctpr_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linafcde` DROP FOREIGN KEY `fk_fcde_articodi`;
ALTER TABLE `linafcde` ADD CONSTRAINT `fk_fcde_articodi` FOREIGN KEY (`articodi`) REFERENCES `linaarti` (`articodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linafcde` DROP FOREIGN KEY `fk_fcde_fche`;
ALTER TABLE `linafcde` ADD CONSTRAINT `fk_fcde_fche` FOREIGN KEY (`emprcodi`, `codmcodi`, `fchenume`) REFERENCES `linafche` (`emprcodi`, `codmcodi`, `fchenume`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linafche` DROP FOREIGN KEY `fk_fche_prov`;
ALTER TABLE `linafche` ADD CONSTRAINT `fk_fche_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linafvde` DROP FOREIGN KEY `fk_fvde_articodi`;
ALTER TABLE `linafvde` ADD CONSTRAINT `fk_fvde_articodi` FOREIGN KEY (`articodi`) REFERENCES `linaarti` (`articodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linafvde` DROP FOREIGN KEY `fk_fvde_fvhe`;
ALTER TABLE `linafvde` ADD CONSTRAINT `fk_fvde_fvhe` FOREIGN KEY (`emprcodi`, `codmcodi`, `fvhenume`) REFERENCES `linafvhe` (`emprcodi`, `codmcodi`, `fvhenume`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linafvhe` DROP FOREIGN KEY `fk_fvde_clie`;
ALTER TABLE `linafvhe` ADD CONSTRAINT `fk_fvde_clie` FOREIGN KEY (`emprcodi`, `cliecodi`) REFERENCES `linaclie` (`emprcodi`, `cliecodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linafvhe` DROP FOREIGN KEY `fk_fvhe_codmcodi`;
ALTER TABLE `linafvhe` ADD CONSTRAINT `fk_fvhe_codmcodi` FOREIGN KEY (`codmcodi`) REFERENCES `linacodm` (`codmcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linapade` DROP FOREIGN KEY `fk_pade_pahe`;
ALTER TABLE `linapade` ADD CONSTRAINT `fk_pade_pahe` FOREIGN KEY (`emprcodi`, `codmcodi`, `pahenume`) REFERENCES `linapahe` (`emprcodi`, `codmcodi`, `pahenume`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linapahe` DROP FOREIGN KEY `fk_pahe_prov`;
ALTER TABLE `linapahe` ADD CONSTRAINT `fk_pahe_prov` FOREIGN KEY (`emprcodi`, `provcodi`) REFERENCES `linaprov` (`emprcodi`, `provcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linaprov` DROP FOREIGN KEY `fk_prov_emprcodi`;
ALTER TABLE `linaprov` ADD CONSTRAINT `fk_prov_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `linasafe` DROP FOREIGN KEY `fk_safe_progcodi`;
ALTER TABLE `linasafe` ADD CONSTRAINT `fk_safe_progcodi` FOREIGN KEY (`progcodi`) REFERENCES `linaprog` (`progcodi`) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE `linasafe` DROP FOREIGN KEY `fk_safe_user`;
ALTER TABLE `linasafe` ADD CONSTRAINT `fk_safe_user` FOREIGN KEY (`emprcodi`, `usercodi`) REFERENCES `linauser` (`emprcodi`, `usercodi`) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE `linauser` DROP FOREIGN KEY `fk_user_emprcodi`;
ALTER TABLE `linauser` ADD CONSTRAINT `fk_user_emprcodi` FOREIGN KEY (`emprcodi`) REFERENCES `linaempr` (`emprcodi`) ON UPDATE CASCADE ON DELETE RESTRICT;
