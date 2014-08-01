//stations
var STATIONID;
$(function () {
	$("#stationdiv").prepend($("<form></form>").attr("id", "stations"));
	$("#stations").prepend($("<select></select>").attr("id", "stationlist"));
	$("#stationlist").attr("onchange", 
		"STATIONID = $(':selected')[0].value; $('#selected').text(STATIONID)");
	$.getJSON('wsdata.php?sensor=stations',	function(data) {
		$.each(data, function(i, station) {
			var option = $("<option></option>")
				.attr("value",station[0])
				.text(station[1]);
			if (i == 0) {
				option.attr("selected","selected");
				STATIONID = station[0];
				$("#selected").text(STATIONID);
			}	
			$("#stationlist").append(option);
		});
	});
});