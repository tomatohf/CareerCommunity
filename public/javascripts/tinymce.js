tinyMCE.init(
	{
		// General options
		mode : "textareas",
		theme : "advanced",
		plugins : "albumphoto,safari,inlinepopups,insertdatetime,emotions,preview,searchreplace,contextmenu,paste,fullscreen,xhtmlxtras",
		language : "ch",
		relative_urls : false,
		remove_script_host : false,
		convert_urls : false,
	
		// Theme options
		theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,formatselect,fontsizeselect,|,justifyleft,justifycenter,justifyright,|,forecolor,backcolor,|,bullist,numlist,|,outdent,indent,blockquote",
		theme_advanced_buttons2 : "pasteword,|,search,|,undo,redo,|,insertdate,inserttime,|,cleanup,removeformat,|,hr,sub,sup,|,charmap,emotions,|,link,unlink,anchor,image,albumphotobtn,|,code,|,fullscreen,|,preview",
		theme_advanced_buttons3 : "",
		theme_advanced_toolbar_location : "top",
		theme_advanced_toolbar_align : "left",
		theme_advanced_statusbar_location : "bottom",
		theme_advanced_resizing : true
	}
);

function add_rich_editor(id) {
	if (!tinyMCE.getInstanceById(id)) {
		tinyMCE.execCommand("mceAddControl", false, id);
	}
	
}

function remove_rich_editor(id) {
	if (tinyMCE.getInstanceById(id)) {
		tinyMCE.execCommand("mceRemoveControl", false, id);
	}
}
