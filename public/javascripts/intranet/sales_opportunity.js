function update_step_done(opportunity_id, step_id, done) {
	$.post(
		"/intranet/employees/" + ACCOUNT_ID + "/sales_opportunities/" + opportunity_id + "/update_step_done",
		{
			step_id: step_id,
			done: done + ""
		},
		function(data) {
			var class_name = "sales_opportunity_step";
			if(done) {
				class_name = "sales_opportunity_step_done";
			}
			
			$("#sales_opportunity_step_" + opportunity_id + "_" + step_id).attr("class", class_name);
		},
		"html"
	);
}


$(document).ready(
	function() {
		$("[class^='sales_opportunity_step']").unbind("click").click(
			function() {
				var ids = $(this).attr("id").substr("sales_opportunity_step_".length).split("_");
				
				update_step_done(ids[0], ids[1], !$(this).hasClass("sales_opportunity_step_done"));
			}
		);
	}
);


function delete_attachment(attachment_id) {
	if(confirm("确定要删除这个附件么 ?")) {
		$("#attachment_id").val(attachment_id);
		$("#delete_attachment_form").submit();
	}
}
