console.log("jscontrol start!");

var parseWeathInfo = function(info) {

	var weatherInfo= info.weatherInfo[0];
	var city, aqi, pm25, hum, pres, tmp, vis, pcpn, qlty, winddir, windsc, windspeed, weather;
	if (weatherInfo) {
		var aqiJson = weatherInfo.aqi;
		var nowJson = weatherInfo.now;
		var basicJson = weatherInfo.basic;

		if (basicJson) {
			city = basicJson.city;
		}

		if (aqiJson) {
			var cityJson = aqiJson.city;
			if (cityJson) {
				aqi = parseInt(cityJson.aqi);
				pm25 = parseInt(cityJson.pm25);
				qlty = cityJson.qlty;
			}
		}

		if (nowJson) {
			hum = parseInt(nowJson.hum);
			pres = parseInt(nowJson.pres);
			tmp = parseInt(nowJson.tmp);
			vis = parseInt(nowJson.vis) * 1000;
			pcpn = parseInt(parseFloat(nowJson.pcpn) * 10);

			var windJson = nowJson.wind;
			var condJson = nowJson.cond;

			if (condJson) {
				weather = condJson.txt;
			}

			if (windJson) {
				winddir = windJson.dir;
				windsc = windJson.sc;
				windspeed = parseInt(windJson.spd);
			}
		}
	}




	var returnStr = {
		"status" : 0,
		"msg" : "success", 
		"data":{
				"params" : [
					"city", "aqi", "pm25", "outsideairquality", 
					"outsidehumid", "barometer", "outsidetemp", 
					"weather_vis", "precipitation", "weather",
					"winddir","windscale","windspeedkmh"
					],
				 "vals" : [
				 	[{"idx":1,"val":city}],
					[{"idx":1,"val":aqi}],
					[{"idx":1,"val":pm25}],
					[{"idx":1,"val":qlty}],
					[{"idx":1,"val":hum}],
					[{"idx":1,"val":pres}],
					[{"idx":1,"val":tmp}],
					[{"idx":1,"val":vis}],
					[{"idx":1,"val":pcpn}],
					[{"idx":1,"val":weather}],
					[{"idx":1,"val":winddir}],
					[{"idx":1,"val":windsc}],
					[{"idx":1,"val":windspeed}],
				]
		}
	}

	return JSON.stringify(returnStr);
}


var jscontrol = function(devinfo, subdevinfo, dataStr) {
	// body...

    var city = "杭州";
	var mycars = new Array();

	var result = httpRequest("get", "https://bizweather.ibroadlink.com/v1/weather?city=" + encodeURI(city), "",  mycars);
	if (result != null) {
		result = result.replace("HeWeather data service 3.0", "weatherInfo");
        
        var resultJson = JSON.parse(result);
        
        return parseWeathInfo(resultJson);
	}
}

console.log("jscontrol end");

