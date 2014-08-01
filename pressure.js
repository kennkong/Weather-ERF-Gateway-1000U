//Barometric Pressure
$(function() {

	$.getJSON('wsdata.php?sensor=pressure', function(data) {
		// Create the chart
		$('#pressure').highcharts({
            		chart: {
                		type: 'spline'
            		},
			credits: {
    				enabled: false
  			},

			exporting: {
         			enabled: false
			},

			title : {
				text : 'Barometric Pressure (inHg)'
			},

			yAxis: {
		  		opposite: true,
					title: {
							text: 'inHg'
					}
			},
			xAxis: {
				type: 'datetime',
					labels: {
						overflow: 'justify'
					}
			},		
			plotOptions: {
                spline: {
                    lineWidth: 1,
                    states: {
                        hover: {
                            lineWidth: 3
                        }
                    },
                    marker: {
                        enabled: false
                    }
                }
            },
			series : [{
				name : 'Pressure',
				data : data,
				tooltip: {
					valueDecimals: 2
				}
			}]
		});
	});

});