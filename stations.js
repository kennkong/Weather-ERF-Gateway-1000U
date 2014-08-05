//stations
$(function () {
	STATIONID=$.query.get('stationid');
	if (STATIONID == "") STATIONID=55;
	$("#stationdiv").prepend($("<form></form>").attr("id", "stations"));
	$("#stations").prepend($("<select></select>").attr("id", "stationlist"));
	$("#stationlist").attr("onchange", 
//		"STATIONID = $(':selected')[0].value; $('#selected').text(STATIONID)");
		"STATIONID = $(':selected')[0].value; location.search='?stationid='+STATIONID;");
	$.getJSON('wsdata.php?sensor=stations',	function(data) {
		$.each(data, function(i, station) {
			var option = $("<option></option>")
				.attr("value",station[0])
				.text(station[0]+" - "+station[1]);
			if (STATIONID == station[0]) {
				option.attr("selected","selected");
			}	
			$("#stationlist").append(option);
		});
	});
});