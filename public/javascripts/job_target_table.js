Ext.onReady(function() {
	alert("ready");

	// create the grid
	var grid = new TableGrid(
		"job_targets_container",
		{
			stripeRows: true, // stripe alternate rows
			border: false,
			
			tbar: new Ext.Toolbar({
		        items:[
		                {
		                    id:'buttonA'
		                    ,text:"Button A"
		                    ,handler: function(){ alert("You clicked Button A"); }
		                }
		                ,
		                new Ext.Toolbar.SplitButton({})
		                ,{
		                    id:'buttonB'
		                    ,text:"Button B"
		                    ,handler: function(){ alert("You clicked Button B"); }
		                }
		                ,
		                '-'
		                ,{
		                    id:'buttonc'
		                    ,text:"Button c"
		                }
		            ]
		        }),
		
		

		        view: new Ext.grid.GroupingView({
		            forceFit:true,
		            groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
		        }),
		
			plugins: new Ext.grid.GridFilters({
				local:true,
				  filters:[
				    {type: 'numeric',  dataIndex: 'tcol-1'},
				    {type: 'string',  dataIndex: 'tcol-0'},
				    {type: 'string', dataIndex: 'tcol-2'}
				]})
		}
	);
	grid.render();
	
	
	grid.addListener('rowcontextmenu', rightClickFn);//右键菜单代码关键部分
	var rightClick = new Ext.menu.Menu({
	    id:'rightClickCont',  //在HTML文件中必须有个rightClickCont的DIV元素
	    items: [
	        {
	            id: 'rMenu1',
	            handler: rMenu1Fn,//点击后触发的事件
	            text: '右键菜单1'
	        },
	        {
	            //id: 'rMenu2',
	            //handler: rMenu2Fn,
	            text: '右键菜单2'
	        }
	    ]
	});
	function rightClickFn(grid,rowindex,e){
	    e.preventDefault();
	    rightClick.showAt(e.getXY());
	}
	function rMenu1Fn(){
	   Ext.MessageBox.alert('right','rightClick');
	}

});


TableGrid = function(table, config) {
  config = config || {};
  Ext.apply(this, config);
  var cf = config.fields || [], ch = config.columns || [];
  table = Ext.get(table);

  var ct = table.insertSibling();

  var fields = [], cols = [];
  var headers = table.query("thead th");
  for (var i = 0, h; h = headers[i]; i++) {
    var text = h.innerHTML;
    var name = "tcol-" + i;

    fields.push(Ext.applyIf(cf[i] || {}, {
      name: name,
      mapping: "td:nth(" + (i+1) + ")/@innerHTML"
    }));

    cols.push(Ext.applyIf(ch[i] || {}, {
      "header": text,
      "dataIndex": name,
      "width": h.offsetWidth,
      "tooltip": h.title,
      "sortable": true
    }));
  }

  var ds  = new Ext.data.GroupingStore({
    reader: new Ext.data.XmlReader({
      record:"tbody tr"
    }, fields),
data: table.dom,
sortInfo: {field: "tcol-1", direction: "ASC"},
groupField: "tcol-2"
  });

  //ds.loadData(table.dom);

  var cm = new Ext.grid.ColumnModel(cols);

  if (config.width || config.height) {
    ct.setSize(config.width || "auto", config.height || "auto");
  } else {
    ct.setWidth(table.getWidth());
  }

  if (config.remove !== false) {
    table.remove();
  }

  Ext.applyIf(this, {
    "ds": ds,
    "cm": cm,
    "sm": new Ext.grid.RowSelectionModel(),
    autoHeight: true,
    autoWidth: false
  });
  TableGrid.superclass.constructor.call(this, ct, {});
};

Ext.extend(TableGrid, Ext.grid.GridPanel);


