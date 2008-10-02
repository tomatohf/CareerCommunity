var photo_selector = {
	
	CURRENT_SHOW_CONTAINER_ID : "",
	
	show_album_photos : function(album_id, photo_list_template) {
		var container_id = "photo_selector_container_" + album_id;
		var container = $(container_id);
		
		if(photo_selector.CURRENT_SHOW_CONTAINER_ID && photo_selector.CURRENT_SHOW_CONTAINER_ID != "") {
			Element.hide(photo_selector.CURRENT_SHOW_CONTAINER_ID);
		}
		photo_selector.CURRENT_SHOW_CONTAINER_ID = container_id;
		
		if(container.childElements().length > 0){
			Effect.Appear(container);
		}
		else {
			photo_selector.fetch_album_photos(album_id, photo_list_template);
		}
	},
	
	fetch_album_photos : function(album_id, photo_list_template) {
		var trigger_id = "photo_selector_trigger_" + album_id;
		var indicator_id = "photo_selector_indicator_" + album_id;
		
		Element.hide(trigger_id);
		Element.show(indicator_id);
		
		new Ajax.Request("/albums/" + album_id + "/fetch_photos", {
			asynchronous: true,
			evalScripts: true,
			onComplete: function(request){
				Element.hide(indicator_id);
				Element.show(trigger_id);
			},
			//onLoading:function(request){},
			method: "get",
			parameters: "photo_list_template=" + photo_list_template
		});
	},
	
	display_fetched_album_photos : function(container_id) {
		if(photo_selector.CURRENT_SHOW_CONTAINER_ID == container_id) {
			Effect.Appear($(container_id));
		}
	}
	
}