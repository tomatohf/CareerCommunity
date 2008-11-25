var step_dd_groups = {};
var group_and_target_id_mapping = {};
var step_id_mapping = {};


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
			re_create_step_dd();
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
		
			tbar: new Ext.Toolbar(
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
			),
		
			bbar: new Ext.Toolbar(
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
			),

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
		
			if(row_index < 0) { return; }
		
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
			re_create_step_dd();
		}
	);



	grid.render();
	
	re_create_step_dd();
}



function create_step_dd() {
	for(var group in step_dd_groups) {
		if(Ext.get(group)) {
		
			var steps = step_dd_groups[group];
			for(var i=0; i<steps.length; i++) {
				var step = steps[i];
				var drag_source = new Ext.dd.DragSource(step, { group: group });
				new Ext.dd.DDTarget(step, group);
				
				drag_source.afterDragDrop = after_step_dd;
				drag_source.afterDragEnter = after_step_dd_enter;
				drag_source.afterDragOut = after_step_dd_out;
				//drag_source.afterDragOver
			}
			
		}
	}
}

function re_create_step_dd() {
	create_step_dd.defer(10);
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

function adjust_step_order(src_id, des_id, groups) {
	var group = groups[0];
	
	var moved_step_id = step_id_mapping[src_id];
	var des_step_id = step_id_mapping[des_id];
	var target_id = group_and_target_id_mapping[group];
	
	var connection = new Ext.data.Connection();
	connection.request(
		{
			url: "/job_targets/" + target_id + "/adjust_step_order",
			method: "POST",
			params: {
				moved_step_id: String(moved_step_id),
				des_step_id: String(des_step_id),
				authenticity_token: form_authenticity_token
			},
			
			callback: function (options, success, response) {
				if(success) {
					if(response.responseText.trim() == "true") {
						var moved_step = Ext.get(src_id);
						moved_step.insertBefore(des_id);
						moved_step.highlight("C3DAF9");
						return;
					}
				}
				
				// not success
				Ext.Msg.show(
					{
						title: "调整步骤次序",
						msg: "调整步骤次序失败! 请重试 ...",
						buttons: Ext.Msg.OK,
						icon: Ext.MessageBox.ERROR,
						minWidth: 250
					}
				);
			}
		}
	);
}


