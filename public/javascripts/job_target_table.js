var steps = {};
var current_step_mapping = {};

var processes = {};
var statuses = {};

var DAY_MSEC = 60*60*24*1000;
var VERY_LARGE_DATE = new Date(2037, 4, 29).getTime();



Ext.QuickTips.init();

JobTownGrid = function(table_id, config) {
	config = config || {};
	Ext.apply(this, config);
	
	var cf = config.fields || [];
	var ch = config.columns || [];
	
	var table_element = Ext.get(table_id);

	var grid_element = table_element.insertSibling();

	var fields = [];
	var columns = [];
	
	//columns.push(new Ext.grid.RowNumberer());
	
	var headers = table_element.query("thead th");
	for(var i = 0; i < 6;  i++) {
		var h = headers[i];
		var text = h.innerHTML;
		var name = "column_" + i;

		fields.push(
			Ext.applyIf(cf[i] || {},
				{
					name: name,
					mapping: "td:nth(" + (i+1) + ")/@innerHTML"
				}
			)
		);

		columns.push(
			Ext.applyIf(ch[i] || {},
				{
					"header": text,
					"dataIndex": name,
					"width": function(h) {
						if(i == 0) {
							return 30;
						}
						else if(i == 1) {
							return 50;
						}
						else {
							return h.offsetWidth;
						}
					}(h),
					"tooltip": h.innerHTML,
					"sortable": !(i == 5),
					"hidden": (i == 4),
					"menuDisabled": (i == 5),
					"renderer": function() {
						if(i == 0) {
							return function(value, metadata, record, rowIndex, colIndex, store) {
								var html = "";
								html += "<div class='";
								if(value == 1) {
									html += "target_starred";
								}
								else {
									html += "target_star";
								}
								html += "'>";
								html += "</div>";
								return html;
							}
						}
						
						else if(i == 1) {
							return function(value) {
								value = parseInt(value);
								
								var html = "";
								html += "<div class='target_info'>";
								
								if(value == VERY_LARGE_DATE) {
									html += "<font color='grey'><i>未设置</i></font>";;
								}
								else if(value > VERY_LARGE_DATE) {
									html += "<font color='red'>已过去</font>";
								}
								else {
									now = new Date();
									due = new Date().setTime(value);
									days = Math.floor((due - now + DAY_MSEC)/DAY_MSEC);
									html += days < 1 ? "<b>今天</b>" : days + "天后";
								}
								
								html += "</div>";
								return html;
							}
						}
						
						else if(i == 2 || i == 3) {
							return function(value) {
								var html = "";
								html += "<div class='target_text'>";
								html += value;
								html += "</div>";
								return html;
							}
						}
						
						else if(i == 4) {
							return function(value) {
								var html = "";
								html += "<div class='target_info'>";
								html += Date.parseDate(value.trim(), "Y-m-d").format("y-m-d");
								html += "</div>";
								return html;
							}
						}
						
						else {
							return function(value) {
								return value;
							}
						}
					}()
				}
			)
		);
	}

	var data_store = new Ext.data.GroupingStore(
		{
			reader: new Ext.data.XmlReader(
				{
					record: "tbody tr",
					id: "td:nth(7)/@innerHTML"
				},
				fields
			),
			
			data: table_element.dom,
			
			sortInfo: {
				field: "column_1",
				direction: "ASC"
			},
			
			groupField: "column_0"
		}
	);

	// no need to load data since we use "data" directly
	//ds.loadData(table_element.dom);

	var column_model = new Ext.grid.ColumnModel(columns);

	// if (config.remove != false) {
		table_element.remove();
	// }

	Ext.applyIf(this,
		{
			"ds": data_store,
			"cm": column_model,
			
			//"selModel": new Ext.grid.CellSelectionModel(),
			
			"autoHeight": true,
			"autoWidth": true,
			"bodyStyle": "width:100%"
		}
	);
	
	JobTownGrid.superclass.constructor.call(this, grid_element, {});
};

Ext.extend(JobTownGrid, Ext.grid.GridPanel);


var grid;

function create_table_grid() {
	
	var grid_view = new Ext.grid.GroupingView(
		{
			forceFit: true,
			groupTextTpl: "{[values.rs.length]} 条目标"
		}
	);
	
	grid_view.addListener(
		"refresh",
		function() {
			reconfig_steps();
		}
	);
	
	grid_toolbar = new Ext.Toolbar(
		{
			items: [
				{
					text: "",
					icon: "/images/job_targets/hide_left_icon.gif",
					cls: "x-btn-icon",
					enableToggle: true,
					pressed: false,
					tooltip: "隐藏左边的功能列表栏, 增大求职目标列表的宽度",
					toggleHandler: function(item, pressed) {
						var left_part = Ext.get("func_list_container");
						left_part.enableDisplayMode("");
						left_part.setVisible(!pressed);
						if(pressed) {
							Ext.get("job_target_list_page").addClass("bigger_job_targets_container");
						}
						else {
							Ext.get("job_target_list_page").removeClass("bigger_job_targets_container");
						}
					}
				},
				
				"-",
				
				{
					//id: "",
					text: "添加流程",
					//icon: "",
					//cls: "x-btn-text-icon",
					handler: function() {
						new_process();
					}
				},
				
				"-",
				
				{
					//id: "",
					text: "添加状态",
					//icon: "",
					//cls: "x-btn-text-icon",
					menu: {
						// id: "",
						items: [
							{
								text: "选择状态的颜色",
								icon: "/images/job_targets/color_palette_icon.gif",
								menu: new Ext.menu.ColorMenu(
									{
										selectHandler: function(cp, color) {
											new_status(color);
										}
									}
								)
							}
						]
					}
				},
				
				"-",
				
				"->",
				
				"今天是 <b>" + new Date().format("Y年m月d日") + "</b>"
			
			]
		}
	);
	
	grid_bottombar = new Ext.Toolbar(
		{
			items: [
				{
					//id: "",
					text: "所有已关闭的目标",
					icon: "/images/job_targets/closed_targets_icon.png",
					cls: "x-btn-text-icon",
					handler: function() {
						window.location.href = "/job_targets/list_closed/" + current_user_id;
					}
				},
				
				"-",
				
				"->",
			
				"共有 <b><span id='unclosed_target_count'>" + target_count + "</span></b> 条未关闭的目标"
			]
		}
	);
	

	grid = new JobTownGrid(
		"job_targets_container",
		{
			stripeRows: false,
			border: false,
			trackMouseOver: false,
			disableSelection: true,
			deferRowRender: false,
		
			tbar: grid_toolbar,
		
			bbar: grid_bottombar,

			view: grid_view,

			plugins: new Ext.grid.GridFilters(
				{
					local: true,
					filters: [
						{
							dataIndex: "column_0",
							type: "boolean"
						},
						
						{
							dataIndex: "column_2",
							type: "string"
						},
						
						{
							dataIndex: "column_3",
							type: "string"
						},

						{
							dataIndex: "column_4",
							type: "date"
						}
					
					]
				}
			)
		}
	);





	grid.addListener(
		"cellcontextmenu",
		function(grid, row_index, cell_index, e) {
			e.preventDefault();
		
			var store = grid.getStore();
			var record = store.getAt(row_index);
		
			var steps_dom = record.data.column_5;
			
			var steps_element = get_element_from_html(steps_dom);
			var target_id = steps_element.id.substr("step_group_".length);
			
			var menu_items = [];
			
			
			var add_step_handler = function(item, e) {
				new_step(target_id, item.process_id, item.text);
			}
			var process_items = [];
			process_items.push("系统添加的流程:");
			process_items.push("-");
			for(var i=0; i<system_processes.length; i++) {
				var process = system_processes[i];
				process_items.push(
					{
						text: process.name,
						process_id: process.id,
						handler: add_step_handler
					}
				);
			}
			process_items.push("-");
			process_items.push("自己添加的流程:");
			process_items.push("-");
			for(var i=0; i<account_processes.length; i++) {
				var process = account_processes[i];
				process_items.push(
					{
						text: process.name,
						process_id: process.id,
						handler: add_step_handler
					}
				);
			}
			
			menu_items.push(
				{
					//id: "",
					text: "添加新的步骤",
					//icon: "",
					menu: {
						items: process_items
					}
				}
			);
			
			
			menu_items.push("-");
			
			var target_starred = (record.data.column_0 == 1);
			menu_items.push(
				{
					//id: "",
					text: target_starred ? "取消星标" : "添加星标",
					icon: "/images/job_targets/" + (target_starred ? "unstarred_icon" : "starred_icon") + ".png",
					handler: function() {
						if(target_starred) {
							update_target_star(target_id, false, store, record);
						}
						else {
							update_target_star(target_id, true, store, record);
						}
					}
				}
			);
			
			
			menu_items.push("-");
			
			menu_items.push(
				{
					//id: "",
					text: "关闭此目标",
					icon: "/images/job_targets/close_target_icon.gif",
					handler: function() {
						Ext.Msg.confirm(
							"关闭目标",
							"确定要关闭这条目标么?",
							function(btn) {
								if (btn == "yes") {
									close_target(target_id, store, record);
								}
							}
						);
					}
				}
			);
		
			var cell_menu_obj = new Ext.menu.Menu(
				{
					//id: "",
					items: menu_items,
					shadow: "frame"
				}
			);
		
		    cell_menu_obj.showAt(e.getXY());
		}
	);
	
	
	
	grid.addListener(
		"statesave",
		function() {
			reconfig_steps();
		}
	);



	grid.render();
	
	reconfig_steps();
	
}



function reconfig_steps() {
	for(var step_dom_id in steps) {
		reconfig_step(step_dom_id);
	}
}

function reconfig_step(step_dom_id) {
	var step = steps[step_dom_id];
	var step_dom = Ext.get(step_dom_id);
	var step_id = step.id;
	
	// create step dd
	var group = "step_group_" + step.target_id;
	if(Ext.get(group) && step_dom) {
		var drag_source = new Ext.dd.DragSource(step_dom_id, { group: group });
		new Ext.dd.DDTarget(step_dom_id, group);
		
		drag_source.afterDragDrop = after_step_dd;
		drag_source.afterDragEnter = after_step_dd_enter;
		drag_source.afterDragOut = after_step_dd_out;
		//drag_source.afterDragOver
	}
	
	
	if(step_dom) {
		// create step menu
		step_dom.addListener(
			"contextmenu",
			show_step_menu,
			null,
			{
				step_id: step_id
			}
		);
	
	
		// create step double click action
		step_dom.addListener(
			"dblclick",
			function(evt, target, options) {
				edit_step_label(options.step_id, steps["step_" + options.step_id].target_id);
			},
			null,
			{
				step_id: step_id
			}
		);
	}
}


function show_step_menu(evt, target, options) {
	//evt.preventDefault();
	evt.stopEvent();
	
	var step_id = options.step_id;
	var step_dom_id = "step_" + step_id;
	var step = steps[step_dom_id];
	var step_label = step.label
	var target_id = step.target_id;
	var process_id = step.process_id;
	var process_name = processes["" + process_id].name;
	var status_id = step.status_id;
	
	menu_items = [
		{
			text: "设置开始日期",
			icon: "/images/job_targets/begin_date_icon.gif",
			menu: new Ext.menu.DateMenu(
				{
					handler: function(dp, date){
						update_step_date(step_id, target_id, date, "begin");
					}
				}
			)
		},
		
		{
			text: "设置结束日期",
			icon: "/images/job_targets/end_date_icon.gif",
			menu: new Ext.menu.DateMenu(
				{
					handler: function(dp, date){
						update_step_date(step_id, target_id, date, "end");
					}
				}
			)
		}
	];
	
	
	menu_items.push("-");
	menu_items.push(
		{
			//id: "",
			text: "删除",
			icon: "/images/delete_small.gif",
			handler: function(item, e) {
				Ext.Msg.confirm(
					"删除步骤",
					"确定要删除步骤 " + step_label + "(" + process_name + ")" + " 么?",
					function(btn) {
						if (btn == "yes") {
							del_step(step_id, target_id);
						}
					}
				);
			}
		}
	);
	
	
	menu_items.push("-");
	
	var set_status_handler = function(item, e) {
		if(item.status_id != status_id) {
			update_step_status(step_id, target_id, item.status_id, item.status_name, item.status_color);
		}
	}
	var status_items = [];
	status_items.push("系统添加的状态:");
	status_items.push("-");
	for(var i=0; i<system_statuses.length; i++) {
		var s = system_statuses[i];
		status_items.push(
			{
				text: s.name,
				status_id: s.id,
				status_name: s.name,
				status_color: s.color,
				checked: (status_id == s.id),
				group: "status_list",
				handler: set_status_handler
			}
		);
	}
	status_items.push("-");
	status_items.push("自己添加的状态:");
	status_items.push("-");
	for(var i=0; i<account_statuses.length; i++) {
		var s = account_statuses[i];
		status_items.push(
			{
				text: s.name,
				status_id: s.id,
				status_name: s.name,
				status_color: s.color,
				checked: (status_id == s.id),
				group: "status_list",
				handler: set_status_handler
			}
		);
	}
	menu_items.push(
		{
			//id: "set_status_menu",
			text: "改变步骤的状态",
			//icon: "/images/job_targets/",
			menu: {
				items: status_items
			}
		}
	);
	
	var set_process_handler = function(item, e) {
		if(item.process_id != process_id) {
			update_step_process(step_id, target_id, item.process_id, item.text);
		}
	}
	var process_items = [];
	process_items.push("系统添加的流程:");
	process_items.push("-");
	for(var i=0; i<system_processes.length; i++) {
		var process = system_processes[i];
		process_items.push(
			{
				text: process.name,
				process_id: process.id,
				checked: (process_id == process.id),
				group: "process_list",
				handler: set_process_handler
			}
		);
	}
	process_items.push("-");
	process_items.push("自己添加的流程:");
	process_items.push("-");
	for(var i=0; i<account_processes.length; i++) {
		var process = account_processes[i];
		process_items.push(
			{
				text: process.name,
				process_id: process.id,
				checked: (process_id == process.id),
				group: "process_list",
				handler: set_process_handler
			}
		);
	}
	menu_items.push(
		{
			//id: "set_process_menu",
			text: "设置步骤的流程",
			//icon: "/images/job_targets/",
			menu: {
				items: process_items
			}
		}
	);
	
	menu_items.push(
		{
			//id: "",
			text: "重命名..",
			//icon: "/images/job_targets/",
			handler: function(item, e) {
				edit_step_label(step_id, target_id);
			}
		}
	);
	
	
	if(current_step_mapping["" + target_id] != "" + step_id) {
		menu_items.push("-");
		menu_items.push(
			{
				//id: "",
				text: "设为当前步骤",
				icon: "/images/job_targets/set_current_step_icon.gif",
				handler: function(item, e) {
					set_current_step(step_id, target_id);
				}
			}
		);
	}
	
	new Ext.menu.Menu(
		{
			id: "step_menu_" + step_id,
			items: menu_items,
			shadow: "frame"
		}
	).showAt(evt.getXY());
}


function edit_step_label(step_id, target_id) {
	var step_dom_id = "step_" + step_id;
	var step = steps[step_dom_id];
	var step_label = step.label;
	var process_name = processes["" + step.process_id].name;
	
	Ext.Msg.prompt(
		"重命名",
		"(" + process_name + ") 输入步骤的名称:",
		function(btn, text) {
			if (btn == "ok"){
				if(step.label != text) {
					update_step_label(step_id, target_id, text);
				}
			}
		},
		null,
		false,
		step_label
	);
}


function new_step(target_id, process_id, process_name) {
	Ext.Msg.prompt(
		"添加步骤",
		"(" + process_name + ") 步骤的名称:",
		function(btn, text) {
			if (btn == "ok"){
				create_step(target_id, process_id, process_name, text);
			}
		}
	);
}


function new_process() {
	Ext.Msg.prompt(
		"添加流程",
		"输入新流程的名称:",
		function(btn, text) {
			if (btn == "ok"){
				var process_name = text.trim();
				if(process_name && process_name != "") {
					create_process(process_name);
				}
			}
		}
	);
}


function new_status(color) {
	Ext.Msg.prompt(
		"添加状态",
		"输入新状态的名称:",
		function(btn, text) {
			if (btn == "ok"){
				var status_name = text.trim();
				if(status_name && status_name != "") {
					create_status(status_name, color);
				}
			}
		}
	);
}


function get_element_from_html(html) {
	var ele = new Ext.Element(document.createElement("div"));
	Ext.DomHelper.overwrite(ele, html);
	return ele.first();
}


function after_step_dd(target, event, id) {
	if(this.id == id) { return false; }
	
	after_step_dd_out(target, event, id);
	
	var groups = [];
	for(var group in target.groups) {
		groups.push(group);
	}
	adjust_step_order(this.id, id, groups);
}

function after_step_dd_enter(target, event, id) {
	if(this.id == id) { return false; }
	
	Ext.get(id).addClass("step_dd_over");
}

function after_step_dd_out(target, event, id) {
	Ext.get(id).removeClass("step_dd_over");
}



function update_grid_store_for_steps(target_id) {
	var store = grid.getStore();
	store.getById(target_id).set("column_5", get_step_group_html(target_id, Ext.get("step_group_" + target_id).dom.innerHTML));
	store.commitChanges();
	
	reconfig_target_steps(target_id);
}

function reconfig_target_steps(target_id) {
	for(var step_dom_id in steps) {
		if(steps[step_dom_id].target_id == target_id) {
			reconfig_step(step_dom_id);
		}
	}
}

function get_step_group_html(target_id, steps_html) {
	var html = "";
	
	html += "<div id='step_group_" + target_id + "'>";
	html += steps_html;
	html += "</div>";
	
	return html;
}

function update_grid_store_for_current_end_date(target_id, date) {
	var store = grid.getStore();
	
	store.getById(target_id).set("column_5", get_step_group_html(target_id, Ext.get("step_group_" + target_id).dom.innerHTML));
	
	var now = new Date().getTime();
	date = parseInt(date);
	var current_end_date = VERY_LARGE_DATE;
	if(date && date != "") {
		if((date + DAY_MSEC) > now) {
			current_end_date = date;
		}
		else {
			current_end_date = VERY_LARGE_DATE + (now - date);
		}
	}
	store.getById(target_id).set("column_1", current_end_date);
	
	store.commitChanges();
	
	reconfig_target_steps(target_id);
}




// +++++++++++++++++++++ ajax requests +++++++++++++++++++++++++++++

function ajax_request(args, success_func, error_msg_args) {
	var connection = new Ext.data.Connection();
	connection.request(
		{
			url: args.url,
			method: args.method || "POST",
			params: args.params,
			
			callback: function (options, success, response) {
				if(success) {
					if(success_func(response)) {
						return;
					}
				}
				
				// not success
				Ext.Msg.show(
					{
						title: error_msg_args.title,
						msg: error_msg_args.msg,
						buttons: Ext.Msg.OK,
						icon: Ext.MessageBox.ERROR,
						minWidth: error_msg_args.minWidth
					}
				);
			}
		}
	);
}

function adjust_step_order(src_id, des_id, groups) {
	var group = groups[0];
	
	var moved_step_id = steps[src_id].id;
	var des_step_id = steps[des_id].id;
	var target_id = group.substr("step_group_".length);
	
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/adjust_step_order",
			params: {
				moved_step_id: String(moved_step_id),
				des_step_id: String(des_step_id),
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// update dom
				var moved_step = Ext.get(src_id);
				moved_step.insertBefore(des_id);
				moved_step.highlight("C3DAF9");
				
				//update grid store
				update_grid_store_for_steps(target_id);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "调整步骤次序",
			msg: "调整步骤次序失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function set_current_step(step_id, target_id) {
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/set_current_step",
			params: {
				step_id: String(step_id),
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// remove old current step
				var old_current_step_dom = Ext.get("step_" + current_step_mapping["" + target_id])
				if(old_current_step_dom) {
					old_current_step_dom.removeClass("step_current");
				}
				
				// set new current step
				current_step_mapping["" + target_id] = "" + step_id;
				Ext.get("step_" + step_id).addClass("step_current");
				
				// update grid store
				update_grid_store_for_current_end_date("" + target_id, steps["step_" + step_id].end_at);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "设置当前步骤",
			msg: "设置当前步骤失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function update_step_label(step_id, target_id, new_label) {
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/update_step_label",
			params: {
				step_id: String(step_id),
				label: new_label,
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// update dom
				Ext.get("step_label_" + step_id).update(new_label, false);
				
				// update data
				steps["step_" + step_id].label = new_label;
				
				// update grid store
				update_grid_store_for_steps(target_id);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "重命名步骤",
			msg: "重命名步骤失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function update_step_process(step_id, target_id, new_process_id, new_process_name) {
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/update_step_process",
			params: {
				step_id: String(step_id),
				process_id: new_process_id,
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// update dom
				Ext.get("step_process_" + step_id).update("("+new_process_name+")", false);
				
				// update data
				steps["step_" + step_id].process_id = new_process_id;
				processes["" + new_process_id] = {
					id: "" + new_process_id,
					name: new_process_name
				};
				
				// update grid store
				update_grid_store_for_steps(target_id);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "设置步骤的流程",
			msg: "设置流程失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function update_step_status(step_id, target_id, new_status_id, new_status_name, new_status_color) {
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/update_step_status",
			params: {
				step_id: String(step_id),
				status_id: new_status_id,
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// update dom
				Ext.get("step_" + step_id).dom.style.color = "#" + new_status_color;
				
				// update data
				steps["step_" + step_id].status_id = new_status_id;
				statuses["" + new_status_id] = {
					id: "" + new_status_id,
					name: new_status_name,
					color: new_status_color
				};
				
				// update grid store
				update_grid_store_for_steps(target_id);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "改变步骤的状态",
			msg: "改变状态失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function del_step(step_id, target_id) {
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/del_step",
			params: {
				step_id: String(step_id),
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// update dom
				Ext.get("step_" + step_id).remove();
				
				// update data
				if(current_step_mapping["" + target_id] == ("" + step_id)) {
					current_step_mapping["" + target_id] = "";
				}
				delete steps["step_" + step_id];
				
				// update grid store
				update_grid_store_for_steps(target_id);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "删除步骤",
			msg: "删除步骤失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function create_step(target_id, process_id, process_name, label) {
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/create_step",
			params: {
				process_id: String(process_id),
				label: label,
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			resp = response.responseText;
			if(resp != "false") {
				var step_ele = get_element_from_html(resp);
				var step_dom_id = step_ele.id;
				var step_id = step_dom_id.substr("step_".length);
				
				// update dom
				Ext.get("step_group_" + target_id).appendChild(step_ele);
				
				// update data
				processes["" + process_id] = {
					id: "" + process_id,
					name: process_name
				};
				steps[step_dom_id] = {
					id: "" + step_id,
					target_id: "" + target_id,
					process_id: "" + process_id,
					status_id: "",
					label: label
				};
				
				// update grid store
				update_grid_store_for_steps(target_id);
				
				// refresh event of added step
				// reconfig_step(step_dom_id);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "添加步骤",
			msg: "添加步骤失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function create_process(process_name) {
	ajax_request(
		{
			url: "/job_targets/create_account_process",
			params: {
				process_name: process_name,
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			resp = response.responseText.trim();
			if(resp != "false") {
				// update data
				account_processes.push(
					{
						id: resp,
						name: Ext.util.Format.htmlEncode(process_name)
					}
				);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "添加流程",
			msg: "添加流程失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function create_status(status_name, color) {
	ajax_request(
		{
			url: "/job_targets/create_account_status",
			params: {
				status_name: status_name,
				status_color: color,
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			resp = response.responseText.trim();
			if(resp != "false") {
				// update data
				account_statuses.push(
					{
						id: resp,
						name: Ext.util.Format.htmlEncode(status_name),
						color: color
					}
				);
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "添加状态",
			msg: "添加状态失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function update_step_date(step_id, target_id, date, at) {
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/update_step_date",
			params: {
				step_id: String(step_id),
				at: at,
				date: date.format("Y-m-d"),
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// update dom
				Ext.get("step_" + at + "_" + step_id).update(date.format("m.d"), false);
				
				// update data
				steps["step_" + step_id][at + "_at"] = date.getTime();
				
				// update grid store
				if((current_step_mapping["" + target_id] == ("" + step_id)) && (at == "end")) {
					update_grid_store_for_current_end_date("" + target_id, date && date.getTime());
				}
				else {
					update_grid_store_for_steps("" + target_id);
				}
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "设置步骤日期",
			msg: "设置步骤日期失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function close_target(target_id, store, record) {
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/close_target",
			params: {
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// update store
				store.remove(record);
				
				// update dom
				target_count = target_count - 1;
				Ext.get("unclosed_target_count").update("" + target_count, false);
				
				// update data
				delete current_step_mapping["" + target_id];
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "关闭目标",
			msg: "关闭目标失败! 请重试 ...",
			minWidth: 250
		}
	);
}


function update_target_star(target_id, starred, store, record) {
	var update_action = starred ? "star_target" : "unstar_target";
	ajax_request(
		{
			url: "/job_targets/" + target_id + "/" + update_action,
			params: {
				authenticity_token: form_authenticity_token
			}
		},
		
		function(response) {
			if(response.responseText.trim() == "true") {
				// update store
				record.set("column_0", (starred ? 1 : 2));
				store.commitChanges();
				
				// update dom
				if("column_0" == store.groupField) {
					store.sort("column_0");
					store.groupBy("column_0", true);
				}
				
				return true;
			}
			
			return false;
		},
		
		{
			title: "设置目标的星标",
			msg: "设置目标的星标失败! 请重试 ...",
			minWidth: 250
		}
	);
}


