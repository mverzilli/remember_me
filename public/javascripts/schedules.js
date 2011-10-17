String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

function MessageFields(row) {
	this._row = $(row);
	this._offset = $('input.offset', this._row);
	this._offsetText = $('span.offset', this._row);
	this._text = $('input.text', this._row);
	this._textText = $('pre.text', this._row);
}

MessageFields.prototype.setOffset = function(value) {
	this._offset.val(value);
	this._offsetText.text(value);
}
MessageFields.prototype.getOffset = function() {
	return this._offset.val();
}
MessageFields.prototype.setText = function(value) {
	this._text.val(value);
	this._textText.text(value);
}
MessageFields.prototype.getText = function() {
	return this._text.val();
}

function MessageControls(row) {
	this._row = $(row);
	this._offset = $('input[name="edit_offset"]', this._row);
	this._text = $('textarea[name="edit_text"]', this._row);
}

MessageControls.prototype.setOffset = function(value) {
	this._offset.val(value);
}

MessageControls.prototype.getOffset = function() {
	return this._offset.val();
}

MessageControls.prototype.setText = function(value) {
	this._text.val(value);
}

MessageControls.prototype.getText = function() {
	return this._text.val();
}

MessageControls.prototype.show_errors = function() {
  this.show_offset_errors_if_must();
  this.show_text_errors_if_must();
}

MessageControls.prototype.is_valid = function(){
  return this.is_offset_present() && this.is_offset_possitive() && this.is_text_present();
}
 
MessageControls.prototype.show_text_errors_if_must = function(){
  this.show_text_error_if('can\'t be blank', !this.is_text_present());
}

MessageControls.prototype.show_offset_errors_if_must = function(){
  this.show_offset_error_if('can\'t be blank', !this.is_offset_present());
  if (this.is_offset_present()) {
    this.show_offset_error_if('can\'t be negative', !this.is_offset_possitive());
  }
}

MessageControls.prototype.is_offset_present = function(){
  return !(this.getOffset().trim() == "");
}

MessageControls.prototype.is_offset_possitive = function(){
  return (this.getOffset() >= 0 );
}

MessageControls.prototype.is_text_present = function(){
  return !(this.getText().trim() == "");
}

MessageControls.prototype.show_offset_error_if = function(message, condition){
  add_error_message_if_must(this._offset, message, condition, this._offset.parent().next());
}

MessageControls.prototype.show_text_error_if = function(message, condition){
  add_error_message_if_must(this._text, message, condition, this._text);
}

function assignMessageValues(dest, source) {
	dest.setOffset(source.getOffset());
	dest.setText(source.getText());
}

function showUnsavedChangesAlert(){
	$.status.showError("There are unsaved changes in your schedule!")
}

function toggleOffset(){
	if ($('#fixed_schedule_option').is(':checked'))
		$('div.offset').css('visibility', 'visible');
	else
		$('div.offset').css('visibility', 'hidden');
}

var timescale;

$(function() {
  $('#fixed_schedule_option').change(function(){
    toggleOffset();
  });

  $('#random_schedule_option').change(function(){
    toggleOffset();
  });

  timescale = $('#schedule_timescale');

  timescale.change(function(){
    updateTimescaleLabels($(this).val());
  });
	timescale.change();

  $('.causesPendingSaveNoticeOnChange').change(function(){
    showUnsavedChangesAlert();
  });

  $('.causesPendingSaveNoticeOnClick').click(function(){
    showUnsavedChangesAlert();
  });

  toggleOffset();
});

function updateTimescaleLabels(new_value){
	$('#random_schedule_option').next().text("Random once " + timescaleToOneString(new_value));
	$('.timescale').text(capitalizedSingular(new_value));
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
  getRow(link).hide();
}

function edit_fields(link, content) {
  var fieldsRow = getRow(link);
  fieldsRow.after(content);
	var controlsRow = getRow(link).next();
	fieldsRow.hide();
	
	assignMessageValues(new MessageControls(controlsRow), new MessageFields(fieldsRow));

	$.instedd.init_components(controlsRow);
	
  //Hide offset control if user is editing a random schedule
  toggleOffset();
	timescale.change();
}

function add_fields(link, association, content) {
  //Replace association placeholder id with a timestamp	
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  var newRowContent = content.replace(regexp, new_id);

  //Add the new instance to the list
  getRow(link).before(newRowContent);
	var fieldsRow = getRow(link).prev().prev();
	var controlsRow = getRow(link).prev();

	fieldsRow.hide();
	$.instedd.init_components(fieldsRow);
	$.instedd.init_components(controlsRow);
	
  //Hide offset control if user is editing a random schedule
  toggleOffset();
	timescale.change();
}

function confirm_changes(buttonOk) {
  if (validate_fields(buttonOk)) {
		
  	var currentRow = getRow(buttonOk);
  	var hiddenRow = $(currentRow).prev();

  	assignMessageValues(new MessageFields(hiddenRow), new MessageControls(currentRow));

  	hiddenRow.show();
  	currentRow.remove();

  	showUnsavedChangesAlert();
		return true;
	}
	return false;
}

function confirm_add(buttonOk) {
		confirm_changes(buttonOk);
}

function revert_changes(buttonCancel) {
	var currentRow = getRow(buttonCancel);
	var hiddenRow = $(currentRow).prev();
	hiddenRow.show();
	currentRow.remove();
}

function revert_add(buttonCancel) {
	var currentRow = getRow(buttonCancel);
	var hiddenRow = $(currentRow).prev();
	hiddenRow.remove();
	currentRow.remove();
}

function getRow(link){
  return $(link).closest(".fields");
}

function add_error_message_if_must(element, message, condition, element_before_error_message) {
  if (condition) {
      var errorElement = $('<label class="error">'+ message + '</label>');
    if (element.hasClass('error')) {
      element_before_error_message.next().remove();
    } else {
      element.addClass('error');
    }
    element_before_error_message.after(errorElement);
  } else {
    if (element.hasClass('error')) {
      element.removeClass('error');
      element_before_error_message.next().remove();
    }
  }
}

function validate_fields(butonOk) {
  var currentRow = getRow(butonOk);
  var controls = new MessageControls(currentRow);
  controls.show_errors();
  return controls.is_valid();
}

function validate_onblur (element) {
  var currentRow = getRow(element);
  var controls = new MessageControls(currentRow);
  controls.show_errors();
}
