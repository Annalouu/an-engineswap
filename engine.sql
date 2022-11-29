CREATE TABLE IF NOT EXISTS `an_engine` (
  `plate` varchar(64) NOT NULL DEFAULT '',
  `exhaust` longtext NULL,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;