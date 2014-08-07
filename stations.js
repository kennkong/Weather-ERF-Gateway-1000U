//stations with synchronous request
STATIONID = "";
$(function () {

    var str = location.search.replace(/^[?#]/, ''); // Remove leading ? or #
	str = str.replace(/[&;]$/, ''); // Remove trailing & or ;
	if (str.length > 0) {
		$.each(str.split("[&;]"), function(i,piece) {
			var key = piece.split("=")[0] || "";
			if (key == "stationid") STATIONID = piece.split("=")[1] || "";
		});
	};
	var scnt = 0;
	$("#stationdiv").hide();
	$("#stationdiv").prepend($("<form></form>").attr("id", "stations"));
	$("#stations").prepend($("<select></select>").attr("id", "stationlist"));
	$("#stationlist").attr("onchange", 
		"STATIONID = $(':selected')[0].value; location.search='?stationid='+STATIONID;");
	$.ajax( {
		url: 'wsdata.php?sensor=stations',
		async: false,
		dataType: "json",
		success: function(data) {
			var scnt = 0;
			console.log(data);
			$.each(data, function(i, station) {
				var option = $("<option></option>")
					.attr("value",station[0])
					.text(station[0]+" - "+station[1]);
				if (STATIONID == "") STATIONID = station[0];
				if (STATIONID == station[0]) {
					option.attr("selected","selected");
				}	
				$("#stationlist").append(option);
				scnt = i;
			});
			if (scnt > 0) $("#stationdiv").show();
			}
		});
});