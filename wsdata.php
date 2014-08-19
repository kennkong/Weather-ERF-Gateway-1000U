<?php
// Note that all this code assumes a single weather station
$stationid = @$_GET['stationid'];
if (!isset($stationid)) $stationid = 55;

try {
	$wdb = new PDO('mysql:dbname=weather');
	$wdb->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
	file_put_contents( 'wsdata.log',
		'Connection error: ' . $e->getMessage(),
		FILE_APPEND);
	exit;
}

$sensor = @$_GET['sensor'];

$sensorids = [
	'insidet'=>[ 'stmtid'=>1, 'sensorid'=>2],
	'insideh'=>[ 'stmtid'=>1, 'sensorid'=>3],
	'outsidet'=>[ 'stmtid'=>1, 'sensorid'=>4],
	'outsideh'=>[ 'stmtid'=>1, 'sensorid'=>5],
	'pressure'=>[ 'stmtid'=>2, 'sensorid'=>6],
	'bpressure'=>[ 'stmtid'=>2, 'sensorid'=>6], // to avoid conflict with graph
	'winddir'=>[ 'stmtid'=>2, 'sensorid'=>7],
	'windspeed'=>[ 'stmtid'=>2, 'sensorid'=>8], // to avoid conflict with graph
	'cwindspeed'=>[ 'stmtid'=>2, 'sensorid'=>8],
	'raincum'=>[ 'stmtid'=>1, 'sensorid'=>9],
	'rainhour'=>[ 'stmtid'=>1, 'sensorid'=>10],
	'rainday'=>[ 'stmtid'=>1, 'sensorid'=>11],
	'rainweek'=>[ 'stmtid'=>6, 'sensorid'=>12],
	'rainmo'=>[ 'stmtid'=>6, 'sensorid'=>13],
	'windgust'=>[ 'stmtid'=>2, 'sensorid'=>15],
	'dewpoint'=>[ 'stmtid'=>1, 'sensorid'=>16],
	'feelslike'=>[ 'stmtid'=>1, 'sensorid'=>14],
	'current'=>[ 'stmtid'=>3, 'sensorid'=>0],
	'min'=>[ 'stmtid'=>4, 'sensorid'=>0],
	'max'=>[ 'stmtid'=>4, 'sensorid'=>0],
	'records'=>[ 'stmtid'=>5, 'sensorid'=>0],
	'stations'=>[ 'stmtid'=>7, 'sensorid'=>0],
	'fallthrough'=> [ 'stmtid'=>0, 'sensorid'=>0], // Must be last
];
$sensorid = $sensorids[$sensor];
$sql = "select (unix_timestamp(P.timestamp) * 1000) as timestamp, ROUND(S.value,2) AS data
FROM weather.sensorvalues S JOIN packets P ON P.id = S.id
WHERE P.stationid = $stationid AND S.sid=".$sensorid['sensorid'];

try {
switch ($sensorid['stmtid']):
case 6:{// All time data
	
	// Limit data set to one per day
	$sql.= " AND P.id in (SELECT packets_id FROM hourly WHERE stations_id = $stationid and `hour`=0)";
	$sql.= ' ORDER BY P.timestamp ASC ';

	print json_encode($wdb->query($sql)->fetchAll(PDO::FETCH_NUM), JSON_NUMERIC_CHECK);

}
break;

case 1:{// Last month data

	// Limit data set to one per hour except last 24
	$sql.= " AND (P.id in (SELECT packets_id FROM hourly 
	WHERE stations_id = $stationid AND midnight > (TO_DAYS(NOW()) - 30))
	OR P.timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR))";
	$sql.= ' ORDER BY P.timestamp ASC ';

	print json_encode($wdb->query($sql)->fetchAll(PDO::FETCH_NUM), JSON_NUMERIC_CHECK);

}
break;

case 2: {// Last 24 hours data

	$sql.= ' AND P.timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)';
	$sql.= ' ORDER BY P.timestamp ASC ';

	print json_encode($wdb->query($sql)->fetchAll(PDO::FETCH_NUM), JSON_NUMERIC_CHECK);

}
break;

case 3: {// Current data
	$sql = "
	SELECT P.id AS pid, (unix_timestamp(P.timestamp) * 1000) as timestamp
	FROM weather.packets P
	WHERE packettype = 2 AND stationid = $stationid
	ORDER BY P.id desc LIMIT 1
	";
	$pds = $wdb->query($sql);
	$pds->bindColumn(1, $pid);
	$pds->bindColumn(2, $pdt);
	$pds->fetch(PDO::FETCH_BOUND);
	$pds->closeCursor();
	
	$row[] = array('current', $pdt);
	
	$sql = 'SELECT S.sid AS sensorid, ROUND(S.value,2) AS data FROM weather.sensorvalues S';
	$sql.= ' WHERE S.id = '.$pid;
	$pds = $wdb->query($sql);
	while ($r = $pds->fetch(PDO::FETCH_ASSOC)) {
		$sid = $r['sensorid'];
		foreach ($sensorids as $key => $values) {
			if ($values['sensorid'] == $sid) break;
		}
		// Kludge
		if (0 == strcmp('windspeed',$key)) $key='cwindspeed';
		if (0 == strcmp('pressure',$key)) $key='bpressure';
		if (0 !== strcmp('fallthrough',$key)) $row[] = array($key,(float)$r['data']);
	}
	$pds->closeCursor();
		
	print json_encode($row, JSON_NUMERIC_CHECK);

}
break;

case 4:{// 24 hour minimums and maximums
$sql1 ="
CREATE TEMPORARY TABLE extrema
SELECT S.sid as sensorid, ".$sensor."(S.value) as mvalue
FROM packets P JOIN sensorvalues S on P.id = S.id
WHERE S.sid in (2,3,4,5,6) AND P.stationid = $stationid
AND P.timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY 1
";

$sql2 ="
SELECT E.sensorid, E.mvalue, MAX(unix_timestamp(P.timestamp) * 1000) as timestamp
FROM packets P JOIN sensorvalues S on P.id = S.id
JOIN extrema E on S.sid = E.sensorid
WHERE S.value = E.mvalue
AND P.stationid = $stationid
AND P.timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY 1, 2
";	
	$wdb->exec($sql1);
	$pds = $wdb->query($sql2);
	while ($r = $pds->fetch(PDO::FETCH_ASSOC)) :
		$sid = $r['sensorid'];
		switch ($sid) :
			case 2: $key = $sensor.'_in_temp'; break;
			case 3: $key = $sensor.'_in_hum'; break;
			case 4: $key = $sensor.'_out_temp'; break;
			case 5: $key = $sensor.'_out_hum'; break;
			case 6: $key = $sensor.'_pres_hg'; break;
			default: $key = 'oops';
		endswitch;
		if (0 != strcmp($key,'oops')) {
			$row[] = array($key, $r['mvalue'], $r['timestamp']);
		}
	endwhile;
	$pds->closeCursor();
		
	print json_encode($row, JSON_NUMERIC_CHECK);

}
break;

case 5:{// Record temps and rain
$sql = "
SELECT R.sid, R.max_flag, R.value, unix_timestamp(P.timestamp) * 1000 as timestamp
FROM packets P JOIN records R ON P.stationid = R.stations_id AND P.id = R.pid
WHERE R.stations_id = $stationid
AND ((R.max_flag = TRUE AND R.sid in (4,10,11,14,15)) OR (R.max_flag = FALSE AND R.sid in(4,14)))
";	
	$pds = $wdb->query($sql);
	while ($r = $pds->fetch(PDO::FETCH_ASSOC)) :
		switch ($r['sid']) :
			case 4: 
				$key = ($r['max_flag']) ? 'hist_max_temp' : 'hist_min_temp';
				break;
			case 10: $key = 'max_rain_hour'; break;
			case 11: $key = 'max_rain_day'; break;
			case 14: 
				$key = $r['max_flag'] ? 'max_feels_like' : 'min_feels_like';
				break;
			case 15: $key = 'max_gust'; break;
			default: $key = 'oops';
		endswitch;
		if (0 != strcmp($key,'oops')) {
			$row[] = array($key, $r['value'], $r['timestamp']);
		}
	endwhile;

	$pds->closeCursor();
	
	print json_encode($row, JSON_NUMERIC_CHECK);

}
break;

case 7: {// Station List
	print json_encode($wdb->query("
	SELECT * FROM stations
	")->fetchAll(PDO::FETCH_ASSOC));
}
break;
endswitch;
} catch (PDOException $e) {
	file_put_contents('wsdata.log', $e->getMessage()."\n", FILE_APPEND);
}
$wdb = null;
?>