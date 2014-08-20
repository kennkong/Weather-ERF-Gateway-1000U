<!DOCTYPE HTML>
<html>
<body>
<?php
error_reporting(E_ALL);
$sql = "UPDATE stations SET ";
$output_flags = 0;
foreach ($_POST as $column => $value) {
	if ($column == "id") continue;
	if ($column == "submit") continue;
	if ($column == "output_flags") {
		foreach ($value as $flag => $fval) {
			$output_flags |= $fval;
		}
	} else {
		$sql.=$column." = '".$value."', ";
	}
}
$sql.="output_flags = $output_flags";
$sql.=" WHERE id = ".$_POST['id'];
//echo $sql."<br>";
try {
	$wdb = new PDO('mysql:dbname=weather');
	$count = $wdb->exec($sql);
} catch (PDOException $e) {
	echo $e->getMessage();
}
echo "success";
?>
</body>
</html>