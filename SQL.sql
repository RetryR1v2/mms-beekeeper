CREATE TABLE `mms_beekeeper` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`ident` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`charident` INT(11) NULL DEFAULT NULL,
	`data` LONGTEXT NULL DEFAULT '{}' COLLATE 'utf8mb3_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='armscii8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=5
;
