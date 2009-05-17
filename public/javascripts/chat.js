var CURRENT_CLIENT_ID;

// common functions
function remove_from_online_list(account_id) {
	var ele = $("online_account_" + account_id);
	if(ele) {
		ele.remove();
	}
}

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

var page_title = document.title;

var blink_page_interval = null;
var blink_page_switch = 0;
var blink_page_text = ["", ""];
function blink_page() {
	$(document).title = (blink_page_switch % 2 == 0) ? blink_page_text[0] + page_title : blink_page_text[1] + page_title;
	blink_page_switch++;
}
function start_blink_page(text) {
	if (!blink_page_interval) {
		blink_page_switch = 0;
		blink_page_text = text;
		blink_page_interval = setInterval(blink_page, 1000);
		
		// add the event handler to clear the blink
		Event.observe(document, "mousemove", stop_blink_page);
		Event.observe(document, "keydown", stop_blink_page);
		Event.observe(document, "focus", stop_blink_page);
		Event.observe(window, "mousemove", stop_blink_page);
		Event.observe(window, "keydown", stop_blink_page);
		Event.observe(window, "focus", stop_blink_page);
	}
}
function stop_blink_page() {
	if (blink_page_interval) {
		clearInterval(blink_page_interval);
		blink_page_interval = null;
		
 		$(document).title = page_title;

		Event.stopObserving(document, "mousemove", stop_blink_page);
		Event.stopObserving(document, "keydown", stop_blink_page);
		Event.stopObserving(document, "focus", stop_blink_page);
		Event.stopObserving(window, "mousemove", stop_blink_page);
		Event.stopObserving(window, "keydown", stop_blink_page);
		Event.stopObserving(window, "focus", stop_blink_page);
	}
}



// personal chat functions
function add_im_listeners(client_id, channels, auth_token) {
	CURRENT_CLIENT_ID = client_id;
	
	
	$(document).observe(
		"juggernaut:connected", 
		function() {
			$("loading_container").remove();
			show_im_chat_container();
			
			$("community_im_status").src = "/images/chats/online_icon.gif";
			$("community_im_status").alt = "即时聊天 在线";
			$("community_im_status").title = "即时聊天 在线";
			
			setTimeout(
				function() {
					update_online_friends(auth_token);
				},
				1.5 * 1000
			);
		}
	);
	
	$("refresh_online_list_link").observe(
		"click",
		function() {
			update_online_friends(auth_token);
		}
	);
	
	$(document).observe(
		"juggernaut:errorConnecting", 
		function() {
			$("community_im_status").src = "/images/chats/offline_icon.gif";
			$("community_im_status").alt = "即时聊天 离线";
			$("community_im_status").title = "即时聊天 离线";
		}
	);
	
	add_common_listeners();
	
	prepare_chatbox_tab();
}

function update_online_friends(auth_token) {
	$("online_list_container").show();
	
	new Ajax.Updater(
		"online_list_container",
        "/chats/update_online_friends",
        {
        	asynchronous:true,
            evalScripts:true,
			method:"post",
            parameters:"authenticity_token=" + auth_token
        }
    );
}

function show_im_chat_container() {
	$("chat_container").show();
}

var tabs = null;
function prepare_chatbox_tab() {
	Ext.onReady(function(){

		tabs = new Ext.TabPanel(
			{
				renderTo: "chatbox_tabs",
				resizeTabs: true,
				minTabWidth: 115,
				tabWidth: 145,
				//width: 600,
				height: 400,
				frame: true
			}
		);
	
	});
}

function add_chatbox(account_id, account_nick, account_img) {
	if(tabs && tabs.rendered) {
		var tab_id = "chatbox_tab_" + account_id;
		var tab = tabs.findById(tab_id);
		if(!tab) {
			tab = tabs.add(
				{
					id: tab_id,
					title: "<img src='" + account_img + "' border='0' width='16' height='16' style='margin-right: 5px; vertical-align: bottom;' />" + account_nick,
					html: get_chatbox_html(account_id, account_nick, account_img),
					closable: true,
					icon: account_img
		    	}
			);
		}
		
		tabs.setActiveTab(tab);
	}
}

function get_chatbox_html(account_id, account_nick, account_img) {
	var html = ""
	
	html += "<div id='chatbox_" + account_id + "' class='chatbox'>";
	html += 	"<div class='float_r chatbox_account_face'>";
	html +=			"<a href='/spaces/show/" + account_id + "' target='_blank'><img src='" + account_img + "' border='0' /></a>"
	html += 	"</div>";
	html += 	"<div style='margin-bottom: 10px;'>";
	html += 		"与 <a href='/spaces/show/" + account_id + "' class='account_nick_link' target='_blank'>" + account_nick + "</a> 的即时聊天 ...";
	html +=		"</div>";
	html += "</div>";
	
	return html;
}

function insert_msg(account_id, msg) {
	var chatbox = $("chatbox_" + account_id);
	if(chatbox) {
		chatbox.insert(
			{
				bottom: msg
			}
		);
	}
}

function add_online_friend(account_id, html) {
	var list = $("online_list");
	if(list && !$("online_account_" + account_id)) {
		list.insert(
			{
				top: html
			}
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
			show_chatroom_chat_container();
			
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

function show_chatroom_chat_container() {
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
		start_blink_chatroom_new_msg();
	}
}

function start_blink_chatroom_new_msg() {
	start_blink_page(["[　　　] - ", "[新消息] - "]);
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

