-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 01, 2014 at 04:24 PM
-- Server version: 5.5.37-MariaDB
-- PHP Version: 5.5.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `weather`
--
CREATE DATABASE IF NOT EXISTS `weather` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `weather`;

-- --------------------------------------------------------

--
-- Stand-in structure for view `historyvalues`
--
CREATE TABLE IF NOT EXISTS `historyvalues` (
`id` int(10) unsigned
,`timestamp` datetime
,`packettype` int(10) unsigned
,`stationid` int(10) unsigned
,`sid` int(10) unsigned
,`value` double
);
-- --------------------------------------------------------

--
-- Table structure for table `hourly`
--

CREATE TABLE IF NOT EXISTS `hourly` (
  `stations_id` int(11) NOT NULL,
  `midnight` int(11) NOT NULL,
  `hour` int(11) NOT NULL,
  `packets_id` int(11) NOT NULL,
  PRIMARY KEY (`stations_id`,`midnight`,`hour`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `packetdump`
--

CREATE TABLE IF NOT EXISTS `packetdump` (
  `pid` int(10) unsigned NOT NULL,
  `http_id` varchar(5) DEFAULT NULL,
  `payload` tinyblob,
  `packettype` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `packets`
--

CREATE TABLE IF NOT EXISTS `packets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `timestamp` datetime NOT NULL COMMENT 'date/time of packet',
  `packettype` int(10) unsigned NOT NULL COMMENT 'packetypes.id',
  `stationid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Index_2` (`timestamp`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=193255 ;

-- --------------------------------------------------------

--
-- Table structure for table `packettypes`
--

CREATE TABLE IF NOT EXISTS `packettypes` (
  `id` int(10) unsigned NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `records`
--

CREATE TABLE IF NOT EXISTS `records` (
  `stations_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL,
  `max_flag` bit(1) NOT NULL,
  `pid` int(11) NOT NULL,
  `value` double DEFAULT NULL,
  PRIMARY KEY (`stations_id`,`sid`,`max_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sensordates`
--

CREATE TABLE IF NOT EXISTS `sensordates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

--
-- Table structure for table `sensordatevalues`
--

CREATE TABLE IF NOT EXISTS `sensordatevalues` (
  `pid` int(10) unsigned NOT NULL,
  `did` int(10) unsigned NOT NULL,
  `date` datetime NOT NULL,
  `prior_value` double NOT NULL,
  PRIMARY KEY (`did`,`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sensors`
--

CREATE TABLE IF NOT EXISTS `sensors` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `format` varchar(45) DEFAULT NULL,
  `valtype` int(10) unsigned DEFAULT NULL,
  `digits` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=18 ;

-- --------------------------------------------------------

--
-- Table structure for table `sensorvalues`
--

CREATE TABLE IF NOT EXISTS `sensorvalues` (
  `id` int(10) unsigned NOT NULL COMMENT 'packets.id',
  `sid` int(10) unsigned NOT NULL COMMENT 'sensors.id',
  `value` double NOT NULL COMMENT 'current value',
  PRIMARY KEY (`id`,`sid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Triggers `sensorvalues`
--
DROP TRIGGER IF EXISTS `sensorvalues_upd_records`;
DELIMITER //
CREATE TRIGGER `sensorvalues_upd_records` AFTER INSERT ON `sensorvalues`
 FOR EACH ROW UPDATE `records`
	SET `pid` = NEW.id, `value` = NEW.value
	WHERE stations_id = (SELECT stationid FROM `packets` WHERE id = NEW.id)
	AND sid = NEW.sid
	AND ((max_flag AND NEW.value > value) OR (NOT max_flag AND NEW.value < value))
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `stations`
--

CREATE TABLE IF NOT EXISTS `stations` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Station ID',
  `description` varchar(25) NOT NULL DEFAULT 'New Station',
  `mac` varchar(11) NOT NULL COMMENT 'Gateway MAC',
  `serial` varchar(8) NOT NULL COMMENT 'Station serial #',
  `station_serial` varchar(16) NOT NULL DEFAULT '7FFF000000000000',
  `ip4` varchar(19) NOT NULL COMMENT 'Gateway IP',
  `wug_id` varchar(12) DEFAULT NULL COMMENT 'Weather Underground Station ID',
  `wug_sec` varchar(12) DEFAULT NULL COMMENT 'Weather Underground security',
  `last_hist_addr` varchar(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='Weather Station identification' AUTO_INCREMENT=57 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_packets_sensordatevalues`
--
CREATE TABLE IF NOT EXISTS `v_packets_sensordatevalues` (
`id` int(10) unsigned
,`timestamp` datetime
,`packettype` int(10) unsigned
,`stationid` int(10) unsigned
,`did` int(10) unsigned
,`date` datetime
,`prior_value` double
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `v_packets_sensorvalues`
--
CREATE TABLE IF NOT EXISTS `v_packets_sensorvalues` (
`id` int(10) unsigned
,`timestamp` datetime
,`packettype` int(10) unsigned
,`stationid` int(10) unsigned
,`sid` int(10) unsigned
,`value` double
);
-- --------------------------------------------------------

--
-- Structure for view `historyvalues`
--
DROP TABLE IF EXISTS `historyvalues`;

CREATE ALGORITHM=UNDEFINED DEFINER=`admin`@`localhost` SQL SECURITY DEFINER VIEW `historyvalues` AS select `P`.`id` AS `id`,`P`.`timestamp` AS `timestamp`,`P`.`packettype` AS `packettype`,`P`.`stationid` AS `stationid`,`S`.`sid` AS `sid`,`S`.`value` AS `value` from (`packets` `P` join `sensorvalues` `S` on((`P`.`id` = `S`.`id`))) where (`P`.`packettype` = 9) order by `P`.`id` desc;

-- --------------------------------------------------------

--
-- Structure for view `v_packets_sensordatevalues`
--
DROP TABLE IF EXISTS `v_packets_sensordatevalues`;

CREATE ALGORITHM=UNDEFINED DEFINER=`admin`@`localhost` SQL SECURITY DEFINER VIEW `v_packets_sensordatevalues` AS select `P`.`id` AS `id`,`P`.`timestamp` AS `timestamp`,`P`.`packettype` AS `packettype`,`P`.`stationid` AS `stationid`,`S`.`did` AS `did`,`S`.`date` AS `date`,`S`.`prior_value` AS `prior_value` from (`packets` `P` join `sensordatevalues` `S` on((`P`.`id` = `S`.`pid`)));

-- --------------------------------------------------------

--
-- Structure for view `v_packets_sensorvalues`
--
DROP TABLE IF EXISTS `v_packets_sensorvalues`;

CREATE ALGORITHM=UNDEFINED DEFINER=`admin`@`localhost` SQL SECURITY DEFINER VIEW `v_packets_sensorvalues` AS select `P`.`id` AS `id`,`P`.`timestamp` AS `timestamp`,`P`.`packettype` AS `packettype`,`P`.`stationid` AS `stationid`,`S`.`sid` AS `sid`,`S`.`value` AS `value` from (`packets` `P` join `sensorvalues` `S` on((`P`.`id` = `S`.`id`)));

--
-- Constraints for dumped tables
--

--
-- Constraints for table `packetdump`
--
ALTER TABLE `packetdump`
  ADD CONSTRAINT `c_packetdump_pid` FOREIGN KEY (`pid`) REFERENCES `packets` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sensorvalues`
--
ALTER TABLE `sensorvalues`
  ADD CONSTRAINT `c_packets_sensorvalues` FOREIGN KEY (`id`) REFERENCES `packets` (`id`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
