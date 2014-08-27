ALTER TABLE `stations`
ADD (
	`timezone` varchar(40) NOT NULL DEFAULT 'UTC' COMMENT 'PHP TimeZone',
	`ping_interval` INT NOT NULL DEFAULT 60 COMMENT 'Gateway ping (seconds)',
	`sensor_interval` INT NOT NULL DEFAULT 4 COMMENT 'Sensor interval (minutes - 1)',
	`history_interval` INT NOT NULL DEFAULT 3 COMMENT 'History interval (0-7)',
	`debug_level` INT NOT NULL DEFAULT 0 COMMENT 'Debug Level (0-2)',
	`output_flags` INT NOT NULL DEFAULT 3 COMMENT 'Output flags'
	)