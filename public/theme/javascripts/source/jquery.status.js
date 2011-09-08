/*
@author : Brian J. Cardiff
@usage :
$.status.showInfo(msg);
$.status.showWarning(msg);
$.status.showError(msg, [kind]);
  * shows error only if no other error of same kind is already displayed.
*/
(function($) {
		
	$.extend({
		status: {
			showError: function(message) {
				this.show(message, 'flash_error');
			},
			showNotice: function(message) {
				this.show(message, 'flash_notice');
			},
			show: function(message, cssClass) {
				$('.flash').remove();
				var message = $('<div>').addClass('flash').addClass(cssClass).text(message);
				$("body").prepend(message);
				this._display_flash(true);
			},
			_display_flash: function(doAnimation){
				// for initial messages
				var message = $(".flash");
				if (message.length > 0) {
					if (doAnimation) {
						message.hide();
					}
					this._set_position(message);
					if (doAnimation) {
						window.setTimeout(function(){ message.slideDown('slow'); }, 200);
					}
				}
			},
			_set_position: function(dom) {
				var header = $("#header");
				var y = header.offset().top + header.height() - 11;
				
				dom.css('left', (($(document).width() - dom.outerWidth()) / 2) + 'px');
				dom.css('top', y + 'px');
			}
		}
	});
		
	$(function(){ $.status._display_flash(true); });
	$(window).resize(function(){ $.status._display_flash(false); });

})(jQuery);
