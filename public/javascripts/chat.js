var CURRENT_CLIENT_ID;

// common functions
function toggle_online_list(show) {
	var left_col = $("chat_left_col");
	var right_col = $("chat_right_col");
	if(show == null) {
		show = (right_col.getStyle("display") == "none");
	}
	right_col.setStyle({
		display:show ? "" : "none"
	});
	right_col.setStyle("marginRight") = show ? "200px" : "0px";
}

function add_common_listeners() {
	$(document).observe(
		"juggernaut:errorConnecting", 
		function() {
			$("loading_container").remove();
			$("error_msg_container").show();
		}
	);
	
	
	// add page changing handler
	Event.observe(
		window,
		"unload",
		function() {
			juggernaut.disconnect();
		}
	);
}

var blink_new_msg_interval = null;
var blink_new_msg_switch = 0;
var page_title = document.title;
function blink_new_msg() {
	$(document).title = (blink_new_msg_switch % 2 == 0) ? "[　　　] - " + page_title : "[新消息] - " + page_title;
	blink_new_msg_switch++;
}
function start_blink_new_msg() {
	if (!blink_new_msg_interval) {
		blink_new_msg_switch = 0;
		blink_new_msg_interval = setInterval(blink_new_msg, 1000);
		
		// add the event handler to clear the blink
		Event.observe(document, "mousemove", stop_blink_new_msg);
		Event.observe(document, "keydown", stop_blink_new_msg);
		Event.observe(document, "focus", stop_blink_new_msg);
		Event.observe(window, "mousemove", stop_blink_new_msg);
		Event.observe(window, "keydown", stop_blink_new_msg);
		Event.observe(window, "focus", stop_blink_new_msg);
	}
}
function stop_blink_new_msg() {
	if (blink_new_msg_interval) {
		clearInterval(blink_new_msg_interval);
		blink_new_msg_interval = null;
		
 		$(document).title = page_title;

		Event.stopObserving(document, "mousemove", stop_blink_new_msg);
		Event.stopObserving(document, "keydown", stop_blink_new_msg);
		Event.stopObserving(document, "focus", stop_blink_new_msg);
		Event.stopObserving(window, "mousemove", stop_blink_new_msg);
		Event.stopObserving(window, "keydown", stop_blink_new_msg);
		Event.stopObserving(window, "focus", stop_blink_new_msg);
	}
}



// personal chat functions
function ensure_refresh_interval_loader() {
	if(refresh_interval_loader) {
		refresh_interval_loader();
	}
	else {
		setTimeout(
			function() {
				ensure_refresh_interval_loader();
			},
			3 * 1000
		);
	}
}



// chatroom functions
function add_chatroom_listeners(client_id, channels, auth_token) {
	CURRENT_CLIENT_ID = client_id;
	
	
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
	
	$("refresh_online_list_link").observe(
		"click",
		function() {
			notify_to_update_online_list(channels, auth_token);
		}
	);
	
	add_common_listeners();
}

function show_chat_container() {
	add_enter_listener();
	$("chat_container").show();
	focus_chat_input();
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

function focus_chat_input() {
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
	
	if(validate_msg()) {
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

function validate_msg() {
	var msg = $("chat_input").value;
	
	if(msg == null) return false;
	if(msg.blank()) return false;
	
	// cut the 200 chars ...
	$("chat_input").value = msg.substr(0, 200);
	return true;
}

var AUTO_SCROLL = true;
function toggle_auto_scroll() {
	AUTO_SCROLL = $("auto_scroll_switch").checked;
}

function on_received_msg(client_id) {
	scroll_chat_area_to_bottom();
	
	if(CURRENT_CLIENT_ID != client_id) {
		start_blink_new_msg();
	}
	$(window).focus();
}

function scroll_chat_area_to_bottom() {
	if(AUTO_SCROLL) {
		var ca = $("chat_area");
		ca.scrollTop = ca.scrollHeight;
	}
}

function set_to_account(name) {
	$("chat_input").value += name;
	
	focus_chat_input();
}

