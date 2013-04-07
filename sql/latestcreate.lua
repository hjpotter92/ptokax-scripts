local tConfig = {
	sDatabase = "latest",
	sMySQLUser = "offliner",
	sMySQLPass = "latest@hhfh"
}

if not luasql then
	require "luasql.mysql"
end

SQLEnv = assert( luasql.mysql() )
SQLCon = assert( SQLEnv:connect( tConfig.sDatabase, tConfig.sMySQLUser, tConfig.sMySQLPass, "localhost", "3306") )

CreateTables = function()
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `entries` (
			`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
			`ctg` VARCHAR(15) NOT NULL,
			`msg` VARCHAR(280) NOT NULL,
			`nick` VARCHAR(30) NOT NULL,
			`date` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `nick_date` (`nick`, `date`),
			INDEX `msg` (`msg`(255))
		)
		COMMENT='Listing of all additions with their tags etc.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `modtable` (
			`id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
			`nick` VARCHAR(30) NOT NULL,
			`added_by` VARCHAR(30) NOT NULL,
			`active` ENUM('Y','N') NULL DEFAULT 'Y',
			`deletions` TINYINT UNSIGNED NOT NULL DEFAULT '0',
			`date` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `nick` (`nick`),
			UNIQUE INDEX `nick_date` (`nick`, `date`),
			INDEX `nick_added_by` (`nick`, `added_by`)
		)
		COMMENT='Table of all the moderators of all time.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `magnets` (
			`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
			`eid` INT UNSIGNED NOT NULL,
			`tth` CHAR(39) NOT NULL,
			`size` BIGINT UNSIGNED NOT NULL DEFAULT '0',
			`nick` VARCHAR(30) NOT NULL DEFAULT 'hjpotter92',
			`date` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			INDEX `tth_size` (`tth`, `size`),
			UNIQUE INDEX `eid_tth` (`eid`, `tth`),
			INDEX `entriedID` (`eid`)
		)
		COMMENT='Table populated with magnets of various entries.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `ctgtable` (
			`id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
			`name` VARCHAR(15) NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `name` (`name`)
		)
		COMMENT='Listing of all categories.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `messages` (
			`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			`message` TEXT NOT NULL,
			`from` VARCHAR(25) NOT NULL DEFAULT 'hjpotter92',
			`to` VARCHAR(25) NOT NULL DEFAULT 'hjpotter92',
			`delivered` ENUM('Y','N') NOT NULL DEFAULT 'N',
			`dated` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `from_dated` (`from`, `dated`),
			INDEX `from` (`from`),
			INDEX `to` (`to`),
			FULLTEXT INDEX `message` (`message`)
		)
		COMMENT='All offline messages users send to each other.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `deletions` (
			`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			`nick` VARCHAR(32) NOT NULL,
			`msg` VARCHAR(250) NOT NULL,
			`dated` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `nick_msg` (`nick`, `msg`)
		)
		COMMENT='The information published when users are about to delete something from their share and others might need it.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `guestbook` (
			`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			`nick` VARCHAR(32) NOT NULL,
			`msg` VARCHAR(250) NOT NULL,
			`dated` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `nick_msg` (`nick`, `msg`)
		)
		COMMENT='Users can leave their comments about their experience on hub.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `news` (
			`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			`nick` VARCHAR(32) NOT NULL,
			`msg` VARCHAR(250) NOT NULL,
			`dated` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `nick_msg` (`nick`, `msg`)
		)
		COMMENT='Recent happenings in and around the campus/country.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `suggestions` (
			`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			`ctg` VARCHAR(15) NOT NULL,
			`msg` VARCHAR(250) NOT NULL,
			`nick` VARCHAR(32) NOT NULL,
			`dated` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `nick_msg` (`nick`, `msg`)
		)
		COMMENT='Suggestions to other users about random stuff.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE IF NOT EXISTS `requests` (
			`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			`ctg` VARCHAR(15) NOT NULL,
			`msg` VARCHAR(250) NOT NULL,
			`nick` VARCHAR(32) NOT NULL,
			`filled` ENUM('Y','N') NOT NULL DEFAULT 'N',
			`dated` DATETIME NOT NULL,
			`filldate` DATETIME NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `nick_msg` (`nick`, `msg`),
			UNIQUE INDEX `ctg_msg` (`ctg`, `msg`)
		)
		COMMENT='Requests from users in any of the categories.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE `buynsell` (
			`id` INT(10) NOT NULL AUTO_INCREMENT,
			`type` ENUM('B','S','D','H','T') NOT NULL DEFAULT 'B',
			`msg` VARCHAR(250) NOT NULL,
			`nick` VARCHAR(32) NOT NULL,
			`dated` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `msg_nick` (`msg`, `nick`),
			INDEX `type` (`type`),
			FULLTEXT INDEX `msg` (`msg`)
		)
		COMMENT='The table storing information about users selling/buying/hiring things etc.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
	local sCreateCode = [[CREATE TABLE `replies` (
			`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			`bns_id` INT(10) UNSIGNED NOT NULL,
			`msg` VARCHAR(250) NOT NULL,
			`nick` VARCHAR(32) NOT NULL,
			`dated` DATETIME NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `bns_id_msg` (`bns_id`, `msg`),
			INDEX `bns_id` (`bns_id`),
			FULLTEXT INDEX `msg` (`msg`)
		)
		COMMENT='Replies to buynsell messages from interested users.'
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]
	local SQLCur = assert( SQLCon:execute(sCreateCode) )
end

CreateTables()
