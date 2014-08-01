//Humidity
$(function () {
	var seriesOptions = [],
		yAxisOptions = [],
		seriesCounter = 0,
		names = ['InsideH', 'OutsideH'],
		colors = Highcharts.getOptions().colors;

	$.each(names, function(i, name) {

		$.getJSON('wsdata.php?sensor='+ name.toLowerCase(),	function(data) {

			seriesOptions[i] = {
				name: name,
				data: data
			};

			// As we're loading the data asynchronously, we don't know what order it will arrive. So
			// we keep a counter and create the chart when all the data is loaded.
			seriesCounter++;

			if (seriesCounter == names.length) {
				createChart();
			}
		});
	});

	// create the chart when all data is loaded
	function createChart() {
    		Highcharts.setOptions({
        		global: {
            			useUTC: false
        		}
    		});

		$('#humidity').highcharts('StockChart', {

			chart: {
            			type: 'line'
        		},

	    		legend: {
	    			enabled: true,
	    			align: 'right',
        			backgroundColor: 'white',
        			borderColor: 'black',
        			borderWidth: 2,
	    			layout: 'vertical',
	    			verticalAlign: 'top',
	    			y: 100,
	    			shadow: true
	    		},

			rangeSelector : {
				inputEnabled: $('#humidity').width() > 480,
				buttons : [{
					type : 'day',
					count : 1,
					text : '1D'
					}, {
					type : 'week',
					count : 1,
					text : '1W'
					}, {
					type: 'all',
					text: 'All'
					}],
				selected : 0
			},

			xAxis: {
            			type: 'datetime',
        		},

			yAxis: {
				title: {
					text: "%"
				}
			},
		    	title : {
				text : 'Humidity (%)'
			},
			credits: {
    				enabled: false
  			},

			exporting: {
         			enabled: false
			},
		    
		    series: seriesOptions
		});
	}

});
