var AlbumPhoto = {
	insertPhoto : function(photo_src, photo_title) {
		var ed = tinyMCEPopup.editor;
		var args = {};

		tinyMCEPopup.restoreSelection();

		// Fixes crash in Safari
		if (tinymce.isWebKit)
			ed.getWin().focus();

		tinymce.extend(args, {
			src : photo_src,
			title : photo_title,
			border : 0
		});

		el = ed.selection.getNode();

		if (el && el.nodeName == 'IMG') {
			ed.dom.setAttribs(el, args);
		} else {
			ed.execCommand('mceInsertContent', false, '<img id="__mce_tmp" />', {skip_undo : 1});
			ed.dom.setAttribs('__mce_tmp', args);
			ed.dom.setAttrib('__mce_tmp', 'id', '');
			ed.undoManager.add();
		}
	},
	
	insertPhotoAndClose : function(photo_src, photo_title) {
		AlbumPhoto.insertPhoto(photo_src, photo_title);
		AlbumPhoto.closePopup();
	},
	
	closePopup : function() {
		tinyMCEPopup.close();
	}
};
