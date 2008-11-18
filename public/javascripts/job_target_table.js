TableGrid = function(table_id, config) {
	config = config || {};
	Ext.apply(this, config);
	
	var cf = config.fields || [];
	var ch = config.columns || [];
	
	var table_element = Ext.get(table_id);

	var grid_element = table_element.insertSibling();

	var fields = [];
	var columns = [];
	
	columns.push(new Ext.grid.RowNumberer());
	
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
					"sortable": true
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
			},
			
			groupField: "column_2"
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
			
			"selModel": new Ext.grid.RowSelectionModel(),
			
			"autoHeight": true,
			"bodyStyle": "width:100%",
			"autoWidth": true
		}
	);
	
	TableGrid.superclass.constructor.call(this, grid_element, {});
};

Ext.extend(TableGrid, Ext.grid.GridPanel);



Ext.onReady(
	
	function() {

		var grid;
	
		grid = new TableGrid(
			"job_targets_container",
			{
				stripeRows: true, // stripe alternate rows
				border: false,
			
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

				view: new Ext.grid.GroupingView(
					{
						forceFit: true,
						groupTextTpl: "{text} ({[values.rs.length]} 条记录)"
					}
				),

				plugins: new Ext.grid.GridFilters(
					{
						local: true,
						filters: [
							{
								dataIndex: "column_0",
								type: "string"
							}
						
						]
					}
				)
			}
		);
	
	
	
	
	
		grid.addListener(
			"rowcontextmenu",
			function(grid, row_index, e) {
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
								text: "menu button",
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
	
	
	
		grid.render();

	}
);


