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


function setup_status_switcher() {
	$("select#status_switcher").unbind("change").change(
		function() {
			window.location.href = "/intranet/employees/" + ACCOUNT_ID + "/sales_opportunities" + $(this).val();
		}
	);
}


$(document).ready(
	function() {
		setup_status_switcher();
		
		if(readonly) {
			$("[class^='sales_opportunity_step']").css("cursor", "auto");
		}
		else {
			$("[class^='sales_opportunity_step']").unbind("click").click(
				function() {
					var ids = $(this).attr("id").substr("sales_opportunity_step_".length).split("_");
				
					update_step_done(ids[0], ids[1], !$(this).hasClass("sales_opportunity_step_done"));
				}
			);
		}
	}
);


function delete_attachment(attachment_id) {
	if(confirm("确定要删除这个附件么 ?")) {
		$("#attachment_id").val(attachment_id);
		$("#delete_attachment_form").submit();
	}
}


function delete_record(record_id) {
	if(confirm("确定要删除这条记录么 ?")) {
		$("#record_id").val(record_id);
		$("#delete_record_form").submit();
	}
}


function delete_todo(todo_id) {
	if(confirm("确定要删除这条事项么 ?")) {
		$("#delete_todo_id").val(todo_id);
		$("#delete_todo_form").submit();
	}
}


function update_todo_done(todo_id, done) {
	var label = "未完成";
	if(done) { label = "已完成"; }
	if(confirm("确定要将这条事项标记为" + label + "么 ?")) {
		$("#update_todo_id").val(todo_id);
		$("#update_todo_done").val(done);
		$("#update_todo_done_form").submit();
	}
}


function delete_comment(comment_id) {
	if(confirm("确定要删除这条评论么 ?")) {
		$("#comment_id").val(comment_id);
		$("#delete_comment_form").submit();
	}
}
