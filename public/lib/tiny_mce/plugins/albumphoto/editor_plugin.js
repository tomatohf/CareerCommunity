(function() {
	tinymce.create("tomato.tinymce.plugins.AlbumPhoto", {
		init : function(ed, url) {
			ed.addCommand("tomatoAlbumPhoto", function() {
				ed.windowManager.open({
					file : url + "/albumphoto.html",
					width : 640,
					height : 480,
					inline : 1
				}, {
					plugin_url : url
				});
			});

			ed.addButton("albumphotobtn", {
				title : "从相册中插入照片",
				cmd : "tomatoAlbumPhoto",
				image : "/images/index/pic_icon.png"
			});
		},

		getInfo : function() {
			return {
				longname : "Album Photo",
				author : "Tomato",
				authorurl : "",
				infourl : "",
				version : "0.1"
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add("albumphoto", tomato.tinymce.plugins.AlbumPhoto);
})();
