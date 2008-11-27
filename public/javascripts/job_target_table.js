var step_and_group_mapping = {};
var group_and_target_id_mapping = {};
var step_id_mapping = {};
var current_step_mapping = {};


TableGrid = function(table_id, config) {
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
	for(var i = 0, h; h = headers[i]; i++) {
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
					"width": h.offsetWidth,
					"tooltip": h.innerHTML,
					"sortable": !(i == 3),
					"hidden": (i == 2),
					"menuDisabled": (i == 3),
					"renderer": (i == 3) ? function(value) {
							return value;
						}
					: ((i == 2) ? function(value) {
								var html = "";
								html += "<div class='target_info'>";
								html += value;
								html += "</div>";
								return html;
							}
						: function(value) {
								var html = "";
								html += "<div class='target_text'>";
								html += value;
								html += "</div>";
								return html;
							}
					)
				}
			)
		);
	}

	var data_store = new Ext.data.GroupingStore(
		{
			reader: new Ext.data.XmlReader(
				{
					record: "tbody tr"
				},
				fields
			),
			
			data: table_element.dom,
			
			sortInfo: {
				field: "column_2", // created_at
				direction: "DESC"
			}
			
			/*
			,
			
			groupField: "column_0"
			*/
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
			"bodyStyle": "width:100%",
			"autoWidth": true
		}
	);
	
	TableGrid.superclass.constructor.call(this, grid_element, {});
};

Ext.extend(TableGrid, Ext.grid.GridPanel);



function create_table_grid() {

	var grid;
	
	var grid_view = new Ext.grid.GroupingView(
		{
			forceFit: true,
			groupTextTpl: "{text} ({[values.rs.length]} 条目标)"
		}
	);
	
	grid_view.addListener(
		"refresh",
		function() {
			reconfig_step();
		}
	);
	
	grid_toolbar = new Ext.Toolbar(
		{
			items: [
				"->",
			
				{
					id: "",
					text: "tool bar button",
					//icon: "",
					//cls: "x-btn-text-icon",
					handler: function() {
						alert("tool bar button");
					}
				}
			
			]
		}
	);
	
	grid_bottombar = new Ext.Toolbar(
		{
			items: [
				"->",
			
				"文字",
			
				"-",
			
				{
					id: "",
					text: "bottom bar button",
					handler: function() {
						alert("bottom bar button");
					}
				}
			
			]
		}
	);
	

	grid = new TableGrid(
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
							type: "string"
						},
						
						{
							dataIndex: "column_1",
							type: "string"
						},

						{
							dataIndex: "column_2",
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
		
			//if(row_index < 0 || cell_index > 2) { return; }
		
			var record = grid.getStore().getAt(row_index);
		
			var record_id = record.data.column_0.trim()
		
			var row_menu_obj = new Ext.menu.Menu(
				{
					id: "row_menu",
					items: [
						{
							id: "",
							text: row_index + " menu button " + cell_index,
							//icon: "",
							handler: function(item, e) {
								alert("menu button");
							}
						}
						
					],
					shadow: "frame"
				}
			);
		
		    row_menu_obj.showAt(e.getXY());
		}
	);
	
	
	
	grid.addListener(
		"statesave",
		function() {
			reconfig_step();
		}
	);



	grid.render();
	
	reconfig_step();
}



function create_step_dd() {
	for(var step in step_and_group_mapping) {
		group = step_and_group_mapping[step];
		if(Ext.get(group)) {
			var drag_source = new Ext.dd.DragSource(step, { group: group });
			new Ext.dd.DDTarget(step, group);
			
			drag_source.afterDragDrop = after_step_dd;
			drag_source.afterDragEnter = after_step_dd_enter;
			drag_source.afterDragOut = after_step_dd_out;
			//drag_source.afterDragOver
		}
	}
}

function create_step_menu() {
	for(var i in step_id_mapping) {
		var step_id = step_id_mapping[i];
				
		Ext.get(i).addListener(
			"contextmenu",
			show_step_menu,
			null,
			{
				step_id: step_id,
				step_dom_id: i
			}
		);
	}
}


function show_step_menu(evt, target, options) {
	//evt.preventDefault();
	evt.stopEvent();
	
	var step_id = options.step_id;
	var step_dom_id = options.step_dom_id
	var target_id = group_and_target_id_mapping[step_and_group_mapping[step_dom_id]];
	
	menu_items = [
		{
			text: "设置开始日期",
			icon: "/images/job_targets/begin_date_icon.gif",
			menu: new Ext.menu.DateMenu(
				{
					handler: function(dp, date){
						alert(date.format("Y-m-d"));
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
						alert(date.format("Y-m-d"));
					}
				}
			)
		}
	];
	
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


function reconfig_step() {
	create_step_dd();
	create_step_menu();
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
	
	var moved_step_id = step_id_mapping[src_id];
	var des_step_id = step_id_mapping[des_id];
	var target_id = group_and_target_id_mapping[group];
	
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
				var moved_step = Ext.get(src_id);
				moved_step.insertBefore(des_id);
				moved_step.highlight("C3DAF9");
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


