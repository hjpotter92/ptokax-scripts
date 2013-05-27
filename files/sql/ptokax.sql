-- --------------------------------------------------------
-- Server version:               5.5.28-1 - (Debian)
-- Server OS:                    debian-linux-gnu
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for ptokax
CREATE DATABASE IF NOT EXISTS `ptokax` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `ptokax`;

-- Dumping structure for table ptokax.comments
CREATE TABLE IF NOT EXISTS `comments` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `error_id` int(10) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `comment` varchar(300) NOT NULL,
  `dated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `error_id_ip` (`error_id`,`ip`),
  KEY `dated` (`dated`),
  FULLTEXT KEY `comment` (`comment`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Storing all comments from users for FAQ';

-- Dumping structure for table ptokax.errors
CREATE TABLE IF NOT EXISTS `errors` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` enum('OFF','INFO','GEN','WEB') NOT NULL,
  `number` smallint(5) unsigned NOT NULL DEFAULT '0',
  `title` varchar(150) NOT NULL DEFAULT 'Welcome to HiT Hi FiT Hai',
  `message` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_number` (`code`,`number`),
  FULLTEXT KEY `title_message` (`title`,`message`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='The table consists of the errors faced by users. It also has an ERROR CODE column to check against.';

-- Dumping structure for table ptokax.ipstats
CREATE TABLE IF NOT EXISTS `ipstats` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(15) NOT NULL,
  `online` enum('n','y') NOT NULL DEFAULT 'y',
  `last_used` datetime NOT NULL DEFAULT '1981-09-30 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ip` (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping structure for table ptokax.ipstats_nicks
CREATE TABLE IF NOT EXISTS `ipstats_nicks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ipstats_id` int(10) unsigned NOT NULL,
  `nick` varchar(32) NOT NULL,
  `used_times` int(10) unsigned NOT NULL DEFAULT '1',
  `online` enum('n','y') NOT NULL DEFAULT 'y',
  `last_used` datetime NOT NULL DEFAULT '1981-09-30 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ipnstats_id` (`ipstats_id`,`nick`),
  KEY `used_times` (`used_times`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping structure for table ptokax.nickstats
CREATE TABLE IF NOT EXISTS `nickstats` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nick` varchar(32) NOT NULL,
  `mode` enum('P','A','S') NOT NULL DEFAULT 'A' COMMENT '(A)ctive or (P)assive mode. (S) is some mode, not sure about what it is.',
  `description` tinytext,
  `email` varchar(100) DEFAULT NULL,
  `sharesize` bigint(20) unsigned NOT NULL DEFAULT '0',
  `profile` tinyint(2) NOT NULL DEFAULT '-1',
  `tag` varchar(100) DEFAULT NULL,
  `client` varchar(30) DEFAULT NULL,
  `hubs` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `slots` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `online` enum('n','y') NOT NULL DEFAULT 'y',
  `last_used` datetime NOT NULL DEFAULT '1981-09-30 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nick` (`nick`),
  KEY `sharesize` (`sharesize`),
  KEY `tag` (`tag`),
  FULLTEXT KEY `description` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping structure for table ptokax.nickstats_login
CREATE TABLE IF NOT EXISTS `nickstats_login` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nickstats_id` int(10) unsigned NOT NULL,
  `ip` varchar(15) NOT NULL,
  `login` datetime NOT NULL DEFAULT '2012-11-19 10:04:30',
  `logout` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `nickstats_id` (`nickstats_id`),
  KEY `ip_login` (`ip`,`login`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
