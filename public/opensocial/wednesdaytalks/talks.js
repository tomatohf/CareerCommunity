function init() {
	load_talk_list();
}

function load_talk_list(page) {
	page = page || 1
	
	gadgets.io.makeRequest(
		"http://www.qiaobutang.com/talks/p/" + page + ".json",
		on_talk_list_load,
		{
			gadgets.io.RequestParameters.CONTENT_TYPE: gadgets.io.ContentType.JSON,
			gadgets.io.RequestParameters.METHOD = gadgets.io.MethodType.GET
		}
	);
}

function on_talk_list_load(resp) {
	var html = "";
	
	var paging_html = get_paging_info_html(resp.data.paging_info);
	
	for(var i=0; i<resp.data.talks.length; i++) {
		var talk = resp.data.talks[i];
		
		html += "<div>";
		html += 	talk.title;
		html += "</div>";
	}
	
	html += paging_html;
	
	document.getElementById("talk_list").innerHTML = html;
}

function get_paging_info_html(paging_info) {
	var html = "";
	
	html += "<div style='text-align: center;'>";
	
	html += 	"<a href='#'>« 上一页</a>"
	
	html += 		" - 第" + paging_info.current_page + "页 / 共" + paging_info.total_pages + "页 - "
	
	html += 	"<a href='#'>下一页 »</a>"
	
	html += "</div>";
	
	return html;
}


