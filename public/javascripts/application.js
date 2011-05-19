function remove_fields(link) {
  $(link).prev("input[type=hidden]").attr("value", '1');
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  //Replace association placeholder id with a timestamp	
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  var newRowContent = content.replace(regexp, new_id);

  //Add the new instance to the list
  $(link).closest(".fields").before(newRowContent);

  //Get the values of the fields of the new object 
  var offset = $('#offset').val();
  var text = $('#text').val();

  //Get the elements where we are going to display the new values
  var offsetCell = $(link).closest(".fields").prev().children('.offset');
  var textCell = $(link).closest(".fields").prev().children('.text')
  
  //Set hidden inputs' values	
  offsetCell.children('.offset').attr("value", offset);
  textCell.children('.text').attr("value", text);

  //Update content to be displayed
  offsetCell.append(offset);
  textCell.append(text);
}