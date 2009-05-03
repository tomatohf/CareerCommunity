function add_listeners(channels, auth_token) {
	$(document).observe(
		"juggernaut:connected", 
		function() {
			setTimeout(
				function() {
					$("loading_container").remove();
					$("chat_container").show();

					notify_to_update_online_list(channels, auth_token);
				},
				2 * 1000
			);
		}
	);

	$(document).observe(
		"juggernaut:errorConnecting", 
		function() {
			$("loading_container").remove();
			$("error_msg_container").show();
		}
	);
}


function notify_to_update_online_list(channels, auth_token) {
	$("online_list_container").show();
	
	var params = "authenticity_token=" + auth_token;
	for(var i=0; i<channels.length; i++) {
		params += "&channels[]=" + channels[i];
	}
	new Ajax.Request(
        "/chats/update_online_list",
        {
        	asynchronous:true,
            evalScripts:true,
			method:"post",
            parameters:params
        }
    );
}


function remove_from_online_list(account_id) {
	var ele = $("online_account_" + account_id);
	if(ele) {
		ele.remove();
	}
}

