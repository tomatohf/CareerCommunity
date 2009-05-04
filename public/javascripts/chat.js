function add_listeners(channels, auth_token) {
	$(document).observe(
		"juggernaut:connected", 
		function() {
			$("loading_container").remove();
			show_chat_container();
			
			setTimeout(
				function() {
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


function show_chat_container() {
	add_enter_listener();
	$("chat_container").show();
	$("chat_input").focus();
}


function remove_from_online_list(account_id) {
	var ele = $("online_account_" + account_id);
	if(ele) {
		ele.remove();
	}
}

function send_msg() {
	var send_form = $("send_msg_form");
	
	if(validate_msg($("chat_input").value)) {
		new Ajax.Request(
			send_form.action, 
			{
				asynchronous:true, 
				evalScripts:true, 
				method:"post", 
				parameters:Form.serialize(send_form)
			}
		);
		
		$("chat_input").value = "";
	}
}

function validate_msg(msg) {
	if(msg == null) return false;
	if(msg.blank()) return false;
	
	return true;
}

function add_enter_listener() {
	$("chat_input").observe(
		"keypress", 
		function(event) {
			if(event.keyCode == Event.KEY_RETURN) {
				send_msg();
				
				// stop processing the event
				Event.stop(event);
			}
		}
	);
}

