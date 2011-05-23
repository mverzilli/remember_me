function showUnsavedChangesAlert(){
	$('.alert').text("There are unsaved changes in your schedule!")
}

function toggleOffsetColumn(){
	if ($('#fixed_schedule_option').is(':checked'))
		$('.offsetColumn').show();
	else
		$('.offsetColumn').hide();
}

$(function() {
	$('#fixed_schedule_option').change(function(){
		toggleOffsetColumn();
	});
	
	$('#random_schedule_option').change(function(){
		toggleOffsetColumn();
	});
	
	var timescale = $('#fixed_schedule_timescale, #random_schedule_timescale, #schedule_timescale');
	
	timescale.change(function(){
		updateTimescaleLabels($(this).val());
	});
	
	$('.causesPendingSaveNoticeOnChange').change(function(){
		showUnsavedChangesAlert();
	});

	$('.causesPendingSaveNoticeOnClick').click(function(){
		showUnsavedChangesAlert();
	});
	
	toggleOffsetColumn();
});

function updateTimescaleLabels(new_value){
	$('#random_schedule_option').next().text("...or send them randomly once " + timescaleToOneString(new_value));
	$('.offsetColumn.header').text(capitalizedSingular(new_value));
}

function capitalizedSingular(timescale) {
	return caseTimescale(timescale, "Hour", "Day", "Week", "Month", "Year", "");
}

function timescaleToOneString(timescale) {
	return caseTimescale(timescale, "an hour", "a day", "a week", "a month", "a year", "");
}

function caseTimescale(value, hour, day, week, month, year, defaultCase){
	switch (value){
		case "hours":
		case "hour":
  			return hour;
		case "days":
		case "day":
  			return day;
		case "weeks":
		case "week":
			return week;
		case "months":
		case "month":
  			return month;
		case "years":
		case "year":
  			return year;
		default:
  			return defaultCase;
	}
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").attr("value", '1');
  $(link).closest(".fields").hide();
}

function edit_fields(link, content) {
  getRow(link).hide();

  content = replace(content, "offsetValuePlaceHolder", getHiddenOffsetValue(link));
  content = replace(content, "textValuePlaceHolder", getHiddenTextValue(link));

  getRow(link).after(content);

  //Hide offset control if user is editing a random schedule
  toggleOffsetColumn();
}

function confirmChange(buttonOk) {
	var currentRow = getRow(buttonOk);

	var newOffset = $('#editOffset', currentRow).val();
	var newText = $('#editText', currentRow).val();

	var hiddenRow = $(currentRow).prev();
  	
	//Set hidden inputs' values	
	$('.offset', hiddenRow).val(newOffset);
	$('.text', hiddenRow).val(newText);

	var offsetColumn = $('.offsetColumn', hiddenRow);
	removePlainText(offsetColumn);
	offsetColumn.append(newOffset);

	var textColumn = $('.textColumn', hiddenRow);
	removePlainText(textColumn);
	textColumn.append(newText);
	
	hiddenRow.show();
	currentRow.remove();
	
	toggleOffsetColumn();	
}

function cancelChange(linkCancel) {
	var currentRow = getRow(linkCancel);
	var hiddenRow = $(currentRow).prev();

	hiddenRow.show();
	currentRow.remove();
	
	toggleOffsetColumn();
}

function removePlainText(jqueryObj) {
	jqueryObj.contents().filter(function() {
	  return this.nodeType == 3;
	}).remove();
} 

function replace(content, placeholder, new_value) {
  return content.replace(new RegExp(placeholder, "g"), new_value);		
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

  $('#offset').val('');
  $('#text').val('');

  var offsetCell = getNewOffsetCell(link);
  var textCell = getNewTextCell(link);  

  //Set hidden inputs' values	
  offsetCell.children('.offset').attr("value", offset);
  textCell.children('.text').attr("value", text);

  //Update content to be displayed
  offsetCell.append(offset);

  textCell.append(text);

  toggleOffsetColumn();
}

function getHiddenOffsetValue(link){
  return getOffsetCell(link).children('.offset').attr("value");
}

function getHiddenTextValue(link){
  return getTextCell(link).children('.text').attr("value");
}


function getRow(link){
  return $(link).closest(".fields");
}

function getNewTextCell(link){
  return getRow(link).prev().children('.textColumn');
}

function getNewOffsetCell(link){
  return getRow(link).prev().children('.offsetColumn');
}

function getOffsetCell(link) {
  return getRow(link).children('.offsetColumn');	
}

function getTextCell(link) {
  return getRow(link).children('.textColumn');		
}