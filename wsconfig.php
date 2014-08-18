<!DOCTYPE HTML>
<html>
<body>
<?php
error_reporting(E_ALL);
$stationid = explode("=", $_SERVER['QUERY_STRING'])[1];
//print_r($_POST);
$sql = "UPDATE stations SET ";
$output_flags = 0;
foreach ($_POST as $column => $value) {
	if ($column == "submit") continue;
	if ($column == "soutput_flags") {
		foreach ($value as $flag => $fval) {
			$output_flags += $fval;
		}
	} else {
		$sql.=substr($column, 1)." = '".$value."', ";
	}
}
$sql.="output_flags = $output_flags WHERE id = $stationid";
//echo $sql."<br>";
try {
	$wdb = new PDO('mysql:dbname=weather');
	$count = $wdb->exec($sql);
//	echo "$count rows updated with message ".$wdb->errorInfo()[2]."<br>";
} catch (PDOException $e) {
	echo $e->getMessage();
}
echo "success";
?>
</body>
</html>