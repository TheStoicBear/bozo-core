CREATE TABLE `characters` (
    `character_id` INT(10) NOT NULL AUTO_INCREMENT,
    `license` VARCHAR(200) NOT NULL DEFAULT '0',
    `first_name` VARCHAR(50) NULL DEFAULT NULL,
    `last_name` VARCHAR(50) NULL DEFAULT NULL,
    `dob` VARCHAR(50) NULL DEFAULT NULL,
    `gender` VARCHAR(50) NULL DEFAULT NULL,
    `cash` INT(10) NULL DEFAULT '0',
    `bank` INT(10) NULL DEFAULT '0',
    `last_location` LONGTEXT NULL DEFAULT '[]',
    PRIMARY KEY (`character_id`) USING BTREE
);
