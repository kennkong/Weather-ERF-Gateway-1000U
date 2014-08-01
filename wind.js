//Wind Speed chart
$(function () {

	var seriesOptions = [],
		yAxisOptions = [{
			opposite: false,
			title: {
				text: 'mph'
			},
			floor: 0,
			minorGridLineWidth: 0,
			gridLineWidth: 0,
			alternateGridColor: null,
			plotBands: [{ // Light air
				from: 0.6,
				to: 3.3,
				color: 'rgba(68, 170, 213, 0.1)',
				label: {
					text: 'Light air',
					style: {
						color: '#606060'
					}
				}
			}, { // Light breeze
				from: 3.3,
				to: 7.4,
				color: 'rgba(0, 0, 0, 0)',
				label: {
					text: 'Light breeze',
					style: {
						color: '#606060'
					}
				}
			}, { // Gentle breeze
				from: 7.4,
				to: 12.3,
				color: 'rgba(68, 170, 213, 0.1)',
				label: {
					text: 'Gentle breeze',
					style: {
						color: '#606060'
					}
				}
			}, { // Moderate breeze
				from: 12.3,
				to: 17.8,
				color: 'rgba(0, 0, 0, 0)',
				label: {
					text: 'Moderate breeze',
					style: {
						color: '#606060'
					}
				}
			}, { // Fresh breeze
				from: 17.8,
				to: 24.5,
				color: 'rgba(68, 170, 213, 0.1)',
				label: {
					text: 'Fresh breeze',
					style: {
						color: '#606060'
					}
				}
			}, { // Strong breeze
				from: 24.5,
				to: 31.3,
				color: 'rgba(0, 0, 0, 0)',
				label: {
					text: 'Strong breeze',
					style: {
						color: '#606060'
					}
				}
			}, { // High wind
				from: 31.3,
				to: 33.5,
				color: 'rgba(68, 170, 213, 0.1)',
				label: {
					text: 'High wind',
					style: {
						color: '#606060'
					}
				}
			}]
		},{
			opposite: true,
			title: {
				text: 'Dir'
			},
			min: 0,
			max: 360,
			tickInterval: 90,
			minorGridLineWidth: 0,
			gridLineWidth: 0,
			alternateGridColor: null,
		}],
		seriesCounter = 0,
		mycharts = [
			{sensor:'windspeed', name:'Wind Speed', type:'column', color: null, yAxisIndex: 0},
			{sensor:'windgust', name:'Gust', type:'scatter', color:'red', yAxisIndex: 0},
			{sensor:'winddir', name:'Dir', type:'scatter', color:'green', yAxisIndex: 1}
		],
		colors = Highcharts.getOptions().colors;

	$.each(mycharts, function(i, mychart) {

		$.getJSON('wsdata.php?sensor='+ mychart.sensor,	function(data) {

			seriesOptions[i] = {
				type: mychart.type,
				name: mychart.name,
				color: mychart.color,
				yAxis: mychart.yAxisIndex,
				data: data
			};

			// As we're loading the data asynchronously, we don't know what order it will arrive. So
			// we keep a counter and create the chart when all the data is loaded.
			seriesCounter++;

			if (seriesCounter == mycharts.length) {
				createChart();
			}
		});
	});
	function createChart() {
	
			Highcharts.setOptions({
        		global: {
            			useUTC: false
        		}
    		});

			$('#windspeed').highcharts({
//            chart: {
//                type: 'column'
//            },
            title: {
                text: 'Wind Speed (mph)'
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
			credits: {
				enabled: false
			},
			exporting: {
				enabled: false
			},
            xAxis: {
                type: 'datetime',
                labels: {
                    overflow: 'justify'
                }
            },
			yAxis: yAxisOptions,
			alignTicks: false,
            tooltip: {
                valueSuffix: ' mph'
            },
            plotOptions: {
                column: {
                    marker: {
                        enabled: false
                    }
                },
				scatter: {
					marker: {
						radius: 1
					}
				}
            },
            series: seriesOptions
        });
	}
 });

