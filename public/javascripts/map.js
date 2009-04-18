/*
	RESERVED ELEMENT IDs:
	
		map_canvas
		
		big_map_link
		small_map_link
		
		wrong_map_link
		no_map_link
		
		point_x_input
		point_y_input
		do_cache_form
*/

window.onunload = GUnload;

var map = null;
var geocoder = null;
var center_point = null;
var type_control = null;
var small_control = null;
var big_control = null;

var point_x;
var point_y;


function draw_map(point) {
	display_map(point);

	document.getElementById("big_map_link").style.display = "";

	if(IS_OWNER) {
		document.getElementById("wrong_map_link").style.display = "";
	}
}

function display_map(point) {
	if (map) {
		center_point = point;
	
		reset_map_center();

		map.addControl(type_control);
		map.addControl(small_control);

		//map.openInfoWindow(map.getCenter(), document.createTextNode("Hello, world"));
	
		show_marker();
	}
}

function show_marker() {
	map.addOverlay(new GMarker(center_point));
}

function reset_map_center() {
	if(map.isLoaded()) {
		map.panTo(center_point);
	}
	else {
		map.setCenter(
			center_point,
			15
		);
	}
}


function big_map() {
	if(map) {
		var mc = document.getElementById("map_canvas");

		mc.style.position = "absolute";

		mc.style.top = "30px";
		mc.style.left = "75px";

		mc.style.border = "10px solid #888888";

		mc.style.width = "800px";
		mc.style.height = "500px";
		map.checkResize();
	
		map.removeControl(small_control);
		map.addControl(big_control);
	
		reset_map_center();
	
		document.getElementById("small_map_link").style.display = "";
		document.getElementById("big_map_link").style.display = "none";
	}
}

function small_map() {
	if(map) {
		var mc = document.getElementById("map_canvas");

		mc.style.borderStyle = "none";

		mc.style.width = "200px";
		mc.style.height = "200px";
		map.checkResize();
	
		map.removeControl(big_control);
		map.addControl(small_control);

		mc.style.top = "";
		mc.style.left = "";

		mc.style.position = "relative";

		reset_map_center();
	
		document.getElementById("big_map_link").style.display = "";
		document.getElementById("small_map_link").style.display = "none";
	}
}

function explain_wrong_map() {
	alert("乔布圈根据搜索*" + ADDRESS_NAME + "*的结果自动呈现地图, 请尽量填写清晰和易于搜索的*" + ADDRESS_NAME + "*, 以获得最佳的地图匹配和呈现效果.");
}

function explain_no_map() {
	alert("乔布圈根据搜索*" + ADDRESS_NAME + "*的结果自动呈现地图, 如果所填写的*" + ADDRESS_NAME + "*无法识别或无法被搜索到, 则无法呈现地图. 请尽量填写清晰和易于搜索的*" + ADDRESS_NAME + "*.");
}


function search_finish(point) {
	if(point) {
		draw_map(point);
		
		point_x = point.x;
		point_y = point.y;
	}
	else {
		point_x = "no";
		point_y = "no";
	
		unrecognize_place();
	}

	if(IS_OWNER) {
		document.getElementById("point_x_input").value = String(point_x);
		document.getElementById("point_y_input").value = String(point_y);
		document.getElementById("do_cache_form").submit();
	}
}

function unrecognize_place() {
	if(IS_OWNER) {
		document.getElementById("no_map_link").style.display = "";
	}
}


function load_map() {
	if (GBrowserIsCompatible()) {
	
		map = new google.maps.Map2(
			document.getElementById("map_canvas"),
			{
				size: new GSize(200, 200)
			}
		);
		
		geocoder = new GClientGeocoder();
		
		type_control = new GMapTypeControl();
		small_control = new GSmallMapControl();
		big_control = new GLargeMapControl();
		
		
		if(IS_POINT_CACHED) {
			if(isNaN(parsed_point_x) || isNaN(parsed_point_y)) {
				unrecognize_place();
			}
			else {
				draw_map(new GPoint(parsed_point_x, parsed_point_y));
			}
		} else {
			if(geocoder) {
				geocoder.getLatLng(
					ADDRESS,
					function(point) {
						search_finish(point);
					}
				);
			}
		}
	}
}


if(AUTO_LOAD) {
	load_map();
}


