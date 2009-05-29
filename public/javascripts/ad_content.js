function toggle_ad_col(show) {
	var ad_col_ele = document.getElementById("ad_col");
	var content_col_ele = document.getElementById("content_col");
	if(show == null) {
		show = (ad_col_ele.style.display == "none");
	}
	toggle_func_list(!show);
	
	return;
	
	content_col_ele.style.marginLeft = show ? "150px" : "0px";
	ad_col_ele.style.display = show ? "" : "none";
}


