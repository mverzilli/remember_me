jQuery(function(){

$('#instedd-footer').append('\
<div id="tools-carousel-wrapper">\
  <ul id="tools-carousel">\
    <li id="geochat">\
      <a href="http://geochat.instedd.org/">\
         <div class="tool-name">Geochat</div>\
      </a>\
    </li>\
    <li id="geochatPolls">\
      <a href="http://instedd.org/technologies/geochat-polls/">\
        <div class="tool-name">Geochat Polls</div>\
      </a>\
    </li>\
    <li id="nuntium">\
      <a href="http://nuntium.instedd.org/">\
        <div class="tool-name">Nuntium</div>\
      </a>\
    </li>\
    <li id="veegilo">\
      <a href="http://veegilo.instedd.org/">\
        <div class="tool-name">Veegilo</div>\
      </a>\
    </li>\
    <li id="remindem">\
      <a href="http://remindem.instedd.org/">\
        <div class="tool-name">Remindem</div>\
      </a>\
    </li>\
    <li id="nuntiumLocalGateway">\
      <a href="http://instedd.org/">\
        <div class="tool-name">Nuntium</div>\
        <div class="tool-sub-name">Local Gateway</div>\
      </a>\
    </li>\
    <li id="mesh4X">\
      <a href="http://instedd.org/technologies/mesh4x/">\
        <div class="tool-name">Mesh4X</div>\
      </a>\
    </li>\
    <li id="reportingWheel">\
      <a href="http://reportingwheel.instedd.org/">\
        <div class="tool-name">Reporting Wheel</div>\
      </a>\
    </li>\
    <li id="resourceMap">\
      <a href="http://resourcemap.instedd.org/">\
        <div class="tool-name">Resource Map</div>\
      </a>\
    </li>\
    <li id="riff">\
      <a href="http://riff.instedd.org/">\
        <div class="tool-name">Riff</div>\
      </a>\
    </li>\
    <li id="seentags">\
      <a href="http://seentags.instedd.org/">\
        <div class="tool-name">Seentags</div>\
      </a>\
    </li>\
    <li id="taskMeUp">\
      <a href="http://taskmeup.instedd.org/">\
        <div class="tool-name">Task Me Up</div>\
      </a>\
    </li>\
    <li id="verboice">\
      <a href="http://verboice.instedd.org/">\
        <div class="tool-name">Verboice</div>\
      </a>\
    </li>\
  </ul>\
</div>\
');

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
  scroll: 10,
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
