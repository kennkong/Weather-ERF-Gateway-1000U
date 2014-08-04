//current
$(function () {
	var extrema = ['max', 'min', 'records'];
	$.getJSON('wsdata.php?sensor=current&stationid='+STATIONID,	function(data) {
		$.each(data, function(i, sensor) {
			if (sensor[0] == "current") {
				var d = new Date(sensor[1]);
				$("#currenttime").html(mytimeformat(d));
			} else {
				$("td#"+sensor[0]).html(sensor[1]);
			}
		});

	});
	$.each(extrema, function (i, extremum) {
		$.getJSON('wsdata.php?sensor='+extremum+'&stationid='+STATIONID, function(data) {
			$.each(data, function(i, sensor) {
				$('td#'+sensor[0]).html(sensor[1]);
				var d = new Date(sensor[2]);
				if (extremum == 'records') {
					$('td#dt_'+sensor[0]).html(d.toLocaleDateString());
				} else {
					$('td#dt_'+sensor[0]).html(mytimeformat(d));
				}
			});

		});
	});
});