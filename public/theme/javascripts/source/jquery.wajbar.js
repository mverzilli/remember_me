/*
 * jQuery Waj-Bar plug-in 1.0 (5/09/2011)
 *
 * Copyright (c) 2008
 *   Juan Wajnerman - http://weblogs.manas.com.ar/waj/
 *   Brian J. Cardiff - http://weblogs.manas.com.ar/bcardiff/
 *
 * Built upon jQuery 1.2.6 (http://jquery.com)
 */
/**
 * The wajbar() method provides a simple way of attaching a progress indicator about amount of chars in user input
 * 
 * It works for <textarea> and <input type="text"> elements. 
 * Those elements should have a maxlength attribute to indicate maximum allowed chars. This 
 * attribute is removed by wajbar() method in order to allow the user to continue typing.
 * 
 * N.B.: textarea maxlength attribute is not a valid HTML.
 *
 * wajbar() method returns DOM that represent the wajbar.
 * 
 * Sample 1:
 * Calling
 *     $('#text1').wajbar(); 
 * the next HTML will create a wajbar after the #text1 element with it's width.
 *     <input type="text" id="text1" maxlength="70" size="40" />
 * 
 * Sample 2:
 * Some options can be passed to wajbar():
 *  - submit: a jQuery selector of elements that should be disabled is user input length is greater that maxlength.
 *  - container: a jQuery selector of desired container element. Good for customizing the layout.
 *
 *     $('#text2').wajbar({
 *         submit: $('#submit2'),
 *         container: $('#container2')
 *     });
 *
 *     <input type="text" id="text2" maxlength="50" />   
 *     <div style="width: 300px;">            
 *         <input type="submit" id="submit2" style="float: left;" />
 *         <div id="container2"></div>
 *     </div>  
 */
(function($) {
	var defaults = {
		submit: null,
		container: null,
		disabler: null,
		wajbar: null,
		maxlength: null,
		currentLength: function(e) {
			return e.val().length;
		}
	};

	$.fn.extend({
		wajbar: function(options) {
			options = $.extend({}, defaults, options || {});
			return $(this).map(function() {

				var _this = $(this);
				var barTemplate = options.wajbar;

				if (!barTemplate) {
					barTemplate = $('<div class="TaskBox"><div class="L"></div><div class="M"><span class="Fill"></span></div><div class="R"></div></div>');
		      
					if (options.container == null) {
						_this.after(barTemplate);
						barTemplate.width(_this.outerWidth()-2); //due to border
					} else {
						options.container.append(barTemplate);
					}
				}

				var bar = $('.Fill', barTemplate);
				var charsLeft = $('.R', barTemplate);
				var charsUsed = $('.L', barTemplate);
				
				var mlength = options.maxlength || _this.attr('maxlength'); // get allowed maxlength

				if ($.browser.msie) _this.attr('maxlength', '9000000000000'); // In IE can't remove maxlength
				else _this.removeAttr('maxlength'); // remove maxlength so user can continue typing
				
				if (_this.attr('readonly') == 'readonly') {
					barTemplate.addClass('readonly');
				}

				var updateUI = function() {
					var currentLength = options.currentLength(_this);
					var percent = Math.min(currentLength / mlength, 1);
					// set (filled) bar length
					bar.css({ "width": (100 * percent) + "%" });

					// disable 'submit' button
					// if (options.submit != null) {
					// 	var disabled = (mlength < currentLength);
					// 	options.submit.attr("jquery-wajbar-disabled", disabled); if (options.disabler) options.disabler(options.submit, disabled);
					// 	else if (disabled) options.submit.attr("disabled", true);
					// 	else options.submit.removeAttr("disabled");
					// }

					// update chars used and left 
					charsUsed.text(currentLength);
					charsLeft.text(mlength - currentLength);
					
					return true;
				};

				_this.keypress(updateUI);
				_this.keyup(updateUI);
				_this.change(function() { window.setTimeout(updateUI, 200); });

				updateUI();

				return barTemplate[0];

			});
		}
	});
})(jQuery);
