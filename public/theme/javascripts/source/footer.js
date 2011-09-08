jQuery(function(){

var apps = [
	{ id:'geochat', url:'http://geochat.instedd.org/', name:'Geochat'},
	{ id:'mesh4X', url:'http://instedd.org/technologies/mesh4x/', name:'Mesh4X'},
	{ id:'nuntium', url:'http://nuntium.instedd.org/', name:'Nuntium'},
	{ id:'nuntiumLocalGateway', url:'http://instedd.org/', name:'Nuntium Local Gateway'},
	{ id:'pollit', url:'http://instedd.org/technologies/geochat-polls/', name:'Pollit'},
	{ id:'remindem', url:'http://remindem.instedd.org/', name:'Remindem'},
	{ id:'reportingWheel', url:'http://reportingwheel.instedd.org/', name:'Reporting Wheel'},
	{ id:'resourceMap', url:'http://resourcemap.instedd.org/', name:'Resource Map'},
	{ id:'riff', url:'http://riff.instedd.org/', name:'Riff'},
	{ id:'seentags', url:'http://seentags.instedd.org/', name:'Seentags'},
	{ id:'taskMeUp', url:'http://taskmeup.instedd.org/', name:'Task Me Up'},
	{ id:'veegilo', url:'http://veegilo.instedd.org/', name:'Veegilo'},
	{ id:'verboice', url:'http://verboice.instedd.org/', name:'Verboice'}
];

$('#instedd-footer').append('\
<div id="tools-carousel-wrapper">\
  <ul id="tools-carousel">\
  </ul>\
</div>\
');

$('#instedd-pulldown').append($("<li>").append($("<ul>")));

$.each(apps, function(index, app){
	$("#tools-carousel").append($("<li>").attr('id',app.id)
		.append($("<a>").attr('href',app.url).append($("<div>").addClass('tool-name').text(app.name)))
	);
	
	$('#instedd-pulldown > li > ul').append($("<li>").append($("<a>").attr('href',app.url).text(app.name)));
});

$("#tools-carousel").append($("<li>"));

function firstInCallback(carousel, item, i) {
  if (i > 1) jQuery(".footer-prev").show();
  else jQuery(".footer-prev").hide();
}

function lastInCallback(carousel, item, i) {
  var total = jQuery("ul#tools-carousel li").length;
  if (i < total) jQuery(".footer-next").show();
  else jQuery(".footer-next").hide();
}

jQuery('#tools-carousel').jcarousel({
  buttonNextHTML: '<a href="#" class="footer-next footer" onclick="return false;"> </a>',
  buttonPrevHTML: '<a href="#" class="footer-prev footer" onclick="return false;"> </a>',
  itemFirstInCallback: firstInCallback,
  itemLastInCallback: lastInCallback
});

jQuery("ul#tools-carousel li").each(function() {
  elem = $(this);
  
  var _app_name = $('#instedd-footer').attr('data-app-name');
  if (typeof _app_name === 'undefined' || _app_name === false) { _app_name = app_name; }
  
  if(elem.attr('id') == _app_name) {
    elem.addClass('selected');
    elem.children().first().click(function(){return false;});
  }
});

});
