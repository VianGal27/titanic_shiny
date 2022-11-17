


function passengers_table_module_js(ns_prefix) {

  $("#" + ns_prefix + "passenger_table").on("click", ".delete_btn", function() {
    Shiny.setInputValue(ns_prefix + "passenger_id_to_delete", this.id, { priority: "event"});
    $(this).tooltip('hide');
  });

  $("#" + ns_prefix + "passenger_table").on("click", ".edit_btn", function() {
    Shiny.setInputValue(ns_prefix + "passenger_id_to_edit", this.id, { priority: "event"});
    $(this).tooltip('hide');
  });
}

