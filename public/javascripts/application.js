function remove_fields(link) {
  alert($(link).prev("input[type=hidden]").attr("name"));
  $(link).prev("input[type=hidden]").attr("value", '1');
  alert($(link).prev("input[type=hidden]").attr("value"));
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).closest().insert({
    before: content.replace(regexp, new_id)
  });
}