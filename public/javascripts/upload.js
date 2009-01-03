function is_double_byte_char(c){
	var pattern = /[^\x00-\xff]/;
	return pattern.test(c);
}

function str_clip(str, len){
	var c_count = 0;
	var total_len = 0;
	for(var i = 0; i < str.length; i++){
		var c = str.charAt(i);
		var c_len = is_double_byte_char(c) ? 2 : 1;
		total_len += c_len;
		if(total_len > len){
			break;
		}
		else{
			c_count += 1;
		}
	}
	
	var clip = str;
	if(str.length > c_count){
		clip = str.substr(0, c_count) + "...";
	}
	
	return clip;
}

var Upload = {
	// The total number of files queued with SWFUpload
	files_queued_count: 0,
	
	file_dialog_complete: function(num_selected, num_queued)
	{
		
	},

	file_queued: function(file)
	{
		div = $("<div></div>").attr({ "id": file.id, "class": "uploaded_photo" });
		div.append($("<div></div>").attr("class", "uploaded_photo_name").html(str_clip(file.name, 10)));
		div.append($("<div></div>").attr("class", "uploaded_photo_status").append("等待中").append("&nbsp;")
			.append("(<a href=\"#\" onclick=\"Upload.cancel_upload('" + file.id + "');return false;\">删除</a>)"));
		div.append($("<div></div>").attr("class", "uploaded_photo_progress").append($("<div></div>")));
		
		$("#upload_queue_container").append(div);
		
		$("#upload_file_queue_count").html(swfu.getStats().files_queued + "");
	},
	
	cancel_upload: function(file_id) {
		swfu.cancelUpload(file_id);
		$("#" + file_id).remove();
		$("#upload_file_queue_count").html(swfu.getStats().files_queued + "");
	},

	upload_start: function(file)
	{
		$("#" + file.id + " div.uploaded_photo_status").html("上传中...");
	},
	
	/* 
		Note: The Linux Flash Player fires a single uploadProgress event after the entire file has 
		been uploaded. This is a bug in the Linux Flash Player that we cannot work around.
	*/
	upload_progress: function(file, bytes, total)
	{
		percent = Math.ceil((bytes / total) * 100);
		$("#" + file.id + " div.uploaded_photo_progress div").width(percent + "%");
	},
	
	upload_error: function(file, code, message)
	{
		if(code == SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED){
			$("#" + file.id).html($("<div></div>").attr("class", "uploaded_photo_name").html(str_clip(file.name, 10)))
				.append($("<div></div>").attr("class", "uploaded_photo_status").append("等待中").append("&nbsp;")
				.append("(<a href=\"#\" onclick=\"Upload.cancel_upload('" + file.id + "');return false;\">删除</a>)"))
				.append($("<div></div>").attr("class", "uploaded_photo_progress").append($("<div></div>")));
		}else{
			$("#" + file.id).html("上传失败")
				.append("<br />")
				.append("再试一次吧")
				.append("<br />")
				.append("(<a href=\"#\" onclick=\"Upload.cancel_upload('" + file.id + "');return false;\">删除</a>)");
		}
	},
	
	upload_success: function(file, data)
	{
		$("#" + file.id).html(data);
	},

	upload_complete: function(file)
	{
		var stats = swfu.getStats();
		$("#upload_file_queue_count").html(stats.files_queued + "");
		$("#upload_file_successful_count").html(stats.successful_uploads + "");
		$("#upload_file_error_count").html(stats.upload_errors + "");
		
		if(!swfu_stopped){
			// Start Next Upload
			swfu.startUpload();
		}
	},
	
	swfupload_loaded: function() {
		$("#loading_swfupload").hide();
		$("#fail_message").hide();
		$("#rich_upload_control_block").show();
	},
	
	swfupload_pre_load: function() {
		$("#fail_message").hide();
		$("#loading_swfupload").show();
		$("#rich_upload_control_block").show();
	},
	
	swfupload_load_failed: function() {
		$("#loading_swfupload").hide();
		$("#rich_upload_control_block").hide();
		$("#fail_message").show();
	}
}



// for SWFUpload

var swfu_stopped = true;

var swfu;

SWFUpload.onload = function(){
	// Setup SWFU object
	var settings = {
		upload_url: upload_action,
		flash_url: "/lib/SWFUpload/swfupload.swf",
		prevent_swf_caching: true,
		file_post_name: "Filedata",

		file_queue_limit: 50,
		file_size_limit: file_size_limitation,
		file_types: "*.jpg;*.jpeg;*.gif;*.png;*.bmp",
		file_types_description: "图片文件",

		// event handlers
		swfupload_loaded_handler : Upload.swfupload_loaded,
		file_queued_handler: Upload.file_queued,
		file_dialog_complete_handler: Upload.file_dialog_complete,
		upload_start_handler: Upload.upload_start,
		upload_progress_handler: Upload.upload_progress,
		upload_error_handler: Upload.upload_error,
		upload_success_handler: Upload.upload_success,
		upload_complete_handler: Upload.upload_complete,
		
		post_params: {
			authenticity_token: encodeURIComponent(form_token)
		},

		debug: false, // Set to true to find out why things aren't working
		
		// SWFObject settings
		minimum_flash_version: "9.0.28",
		swfupload_pre_load_handler: Upload.swfupload_pre_load,
		swfupload_load_failed_handler: Upload.swfupload_load_failed,
		
		
		// for Flash Player 10 and swfupload v2.2
		button_placeholder_id: "add_file_button",
		button_image_url: "/lib/SWFUpload/add_file_button.jpg",
		
		//button_text: "选择图片文件",
		//button_text_top_padding: 0,
		//button_text_left_padding: 0,
		
		button_width: 92,
		button_height: 20,
		
		button_disabled: is_account_limited,
		button_cursor: SWFUpload.CURSOR.HAND
	};
	
	swfu = new SWFUpload(settings);
}

$(document).ready(function() {
	// Add Event Handlers
	$("#add_file_button").click(function() { swfu.selectFiles(); });
	$("#upload_file_button").click(function() { swfu.startUpload(); swfu_stopped = false; });
	$("#stop_upload_file_button").click(function() { swfu.stopUpload(); swfu_stopped = true; });
	
	$("#fail_message").hide();
	$("#rich_upload_control_block").hide();
	$("#loading_swfupload").show();
});


