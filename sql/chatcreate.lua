local tConfig = {
	sDatabase = "stats",
	sMySQLUser = "offliner",
	sMySQLPass = "latest@hhfh"
}

if not luasql then
	require "luasql.mysql"
end

SQLEnv = assert( luasql.mysql() )
SQLCon = assert( SQLEnv:connect( tConfig.sDatabase, tConfig.sMySQLUser, tConfig.sMySQLPass, "localhost", "3306") )

function InitialiseDB( SQLCon )
	local SQLRes = assert( SQLCon:execute([[CREATE TABLE IF NOT EXISTS `chatstat` (
				`id` BIGINT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`username` VARCHAR(25) NOT NULL,
				`totalcount` BIGINT(20) UNSIGNED NOT NULL,
				`thismonth` BIGINT(20) UNSIGNED NOT NULL,
				`thisweek` INT(10) UNSIGNED NOT NULL,
				`lastweek` INT(10) UNSIGNED NOT NULL,
				`lastmonth` INT(10) UNSIGNED NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `id` (`id`),
			UNIQUE INDEX `username` (`username`)
		)
		ENGINE=MyISAM ]]) )
	local SQLRes = assert( SQLCon:execute([[CREATE TABLE IF NOT EXISTS `datedcount` (
				`id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
				`ondate` DATE NOT NULL,
				`chatcount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`pmcount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`botpmcount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
			PRIMARY KEY (`id`),
			UNIQUE INDEX `ondate` (`ondate`),
			INDEX `id` (`id`)
		)
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]) )
end
