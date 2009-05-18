var CURRENT_CLIENT_ID;

// common functions
function validate_msg() {
	var msg = $("chat_input").value;
	
	if(msg == null) return false;
	if(msg.blank()) return false;
	
	// cut the 200 chars ...
	$("chat_input").value = msg.substr(0, 200);
	return true;
}

function show_chat_container(enter_handler, args) {
	add_enter_listener(enter_handler, args);
	$("chat_container").show();
	focus_chat_input();
}

function add_enter_listener(handler, args) {
	if(!args) { args = []; }
	
	$("chat_input").observe(
		"keypress", 
		function(event) {
			if(event.keyCode == Event.KEY_RETURN) {
				handler.apply(this, args);
				
				// stop processing the event
				Event.stop(event);
			}
		}
	);
}

function focus_chat_input() {
	$("chat_input").focus();
}

var AUTO_SCROLL = true;
function toggle_auto_scroll() {
	AUTO_SCROLL = $("auto_scroll_switch").checked;
}

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
			if($("loading_container")) { $("loading_container").remove(); }
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
	blink_page_text = text;
	
	if (!blink_page_interval) {
		blink_page_switch = 0;
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
var blink_tab_interval = {};
var blink_tab_switch = {};
var blink_tab_text = {};
var blink_tab_title = {};
function blink_tab(account_id) {
	var tab = find_tab(account_id)
	if(!tab) { return; }
	
	var tab_title = blink_tab_title[account_id];
	
	var blink_text = blink_tab_text[account_id];
	if(!blink_text) {
		blink_text = ["", ""];
	}
	
	tab.setTitle((blink_tab_switch[account_id] % 2 == 0) ? blink_text[0] + tab_title : blink_text[1] + tab_title);
	blink_tab_switch[account_id]++;
}
function start_blink_tab(text, account_id) {
	blink_tab_text[account_id] = text;
	
	if (!blink_tab_interval[account_id]) {
		blink_tab_switch[account_id] = 0;
		
		var tab = find_tab(account_id)
		if(!tab) { return; }
		
		blink_tab_title[account_id] = tab.title;
		
		blink_tab_interval[account_id] = setInterval(
			function() {
				blink_tab(account_id);
			},
			1000
		);
	}
}
function stop_blink_tab(account_id) {
	if (blink_tab_interval[account_id]) {
		clearInterval(blink_tab_interval[account_id]);
		blink_tab_interval[account_id] = null;
		
		var tab = find_tab(account_id)
		if(!tab) { return; }
		
 		tab.setTitle(blink_tab_title[account_id]);
	}
}

function find_tab(account_id) {
	var tab = null;
	
	if(tabs) {
		tab = tabs.findById("chatbox_tab_" + account_id);
	}
	
	return tab;
}

function add_im_listeners(client_id, channels, auth_token) {
	CURRENT_CLIENT_ID = client_id;
	
	
	$(document).observe(
		"juggernaut:connected", 
		function() {
			if($("loading_container")) { $("loading_container").remove(); }
			show_chat_container(send_im_msg);
			
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
				height: 410, // height of chatbox, plus 20
				frame: true
			}
		);
	
	});
}

function add_chatbox(account_id, account_nick, account_img, silent) {
	var tab = null;
	if(tabs && tabs.rendered) {
		var tab_id = "chatbox_tab_" + account_id;
		tab = tabs.findById(tab_id);
		if(!tab) {
			tab = tabs.add(
				{
					id: tab_id,
					title: "<img src='" + account_img + "' border='0' width='16' height='16' style='margin-right: 5px; vertical-align: bottom;' />" + account_nick,
					html: get_chatbox_html(account_id, account_nick, account_img),
					closable: true
		    	}
			);
			
			// add listeners
			var clear_tab_blink_handler = function() {
				stop_blink_tab(account_id);
				scroll_chatbox_to_bottom(account_id);
			}
			tab.addListener("activate", clear_tab_blink_handler);
			tab.addListener("show", clear_tab_blink_handler);
			tab.addListener("close", clear_tab_blink_handler);
		}
		
		if(!silent || !get_active_tab()) {
			tabs.setActiveTab(tab);
		}
	}
	
	focus_chat_input();
	
	return tab;
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
		
		on_received_im_msg(account_id, account_id)
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

function get_active_tab() {
	var tab = null;
	
	if(tabs) {
		tab = tabs.getActiveTab();
		if(tab) {
			// the active tab may be not displayed on the page (be closed, for instance)
			tab = tabs.findById(tab.getId());
		}
	}
	
	return tab;
}

function send_im_msg() {
	if(!tabs) { return; }
	
	var tab = get_active_tab();
	if(!tab) { return; }
	
	var to_account_id = tab.getId().substr("chatbox_tab_".length);
	
	if(validate_msg()) {
		var send_form = $("send_msg_form");
		
		new Ajax.Request(
			send_form.action, 
			{
				asynchronous:true, 
				evalScripts:true, 
				method:"post", 
				parameters:"to_account_id=" + to_account_id + "&" + Form.serialize(send_form)
			}
		);
		
		$("chat_input").value = "";
	}
}

function insert_im_msg(receiver_id, account_id, account_nick, account_img, msg) {
	var chatbox = null;
	
	if(CURRENT_CLIENT_ID == account_id) {
		chatbox = $("chatbox_" + receiver_id);
	}
	else {
		add_chatbox(account_id, account_nick, account_img, true);
		
		chatbox = $("chatbox_" + account_id);
	}
	
	if(chatbox) {
		chatbox.insert(
			{
				bottom: msg
			}
		);
		
		on_received_im_msg(receiver_id, account_id);
	}
}

function on_received_im_msg(receiver_id, account_id) {	
	if(CURRENT_CLIENT_ID != account_id) {
		scroll_chatbox_to_bottom(account_id);
		
		start_blink_im_new_msg(account_id);
	}
	else {
		scroll_chatbox_to_bottom(receiver_id);
	}
}

function scroll_chatbox_to_bottom(account_id) {
	if(AUTO_SCROLL) {
		var chatbox = $("chatbox_" + account_id);
		if(chatbox) {
			chatbox.scrollTop = chatbox.scrollHeight;
		}
	}
}

function start_blink_im_new_msg(account_id) {
	start_blink_page(["[　　　] - ", "[新消息] - "]);
	
	var active_tab = get_active_tab();
	if(active_tab && (active_tab.getId() != "chatbox_tab_" + account_id)) {
		start_blink_tab(["", "<b>*</b> "], account_id);
	}
}




// chatroom functions
function add_chatroom_listeners(client_id, channels, auth_token) {
	CURRENT_CLIENT_ID = client_id;
	
	
	$(document).observe(
		"juggernaut:connected", 
		function() {
			if($("loading_container")) { $("loading_container").remove(); }
			show_chat_container(send_msg);
			
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
		if(ca) {
			ca.scrollTop = ca.scrollHeight;
		}
	}
}

function set_to_account(name) {
	$("chat_input").value += name;
	
	focus_chat_input();
}

