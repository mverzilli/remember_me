/*
 * jQuery Waj-Bar plug-in 0.2 (2/12/2008)
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
        /*getColor: function(percent) {
            // set color
            var red, green;
            if (percent <= .5) {
                red = 2 * percent * 255;
                green = 255;
            } else {
                red = 255;
                green = (2 - 2 * percent) * 255;
            }
            return "rgb(" + Math.floor(red) + "," + Math.floor(green) + ",0)";
        },*/
     /*   updateCharsLeftMessage: function(dom, count) {
            if (count == 0)
                dom
                    .text('no chars left')
                    .css({ color: '' });
            else if (count < 0)
                dom
                    .text(-count + ' chars over')
                    .css({ color: 'rgb(255,0,0)' });
            else
                dom
                   .text(count + ' chars left')
                    .css({ color: '' });
        }*/
    };

    var idFactory = 0;
    var createId = function() {
        idFactory++;
        return "jquery-wajbar-generatedid-" + idFactory;
    };

    $.fn.extend({
        wajbar: function(options) {
            
            options = $.extend({}, defaults, options || {});
            return $(this).map(function() {
                if(!$(this).hasClass('hasWajBar')){
                    var _this = $(this);
                    var barTemplate = options.wajbar;

                    if (!barTemplate) {
                        barTemplate = $('<div class="WajBarBox"><div class="CharsUsed">0</div><div class="Border"><span class="Bar"></span></div><div class="CharsLeft">140</div></div>');
                        if (options.container == null) {
                            _this.after(barTemplate);
                            barTemplate.width(_this.width());
                        } else {
                            options.container.append(barTemplate);
                        }
                    }
                    _this.addClass('hasWajBar');

                    var bar = $('.Bar', barTemplate);
                    var charsLeft = $('.CharsLeft', barTemplate);
                    var charsUsed = $('.CharsUsed', barTemplate);

                    var mlength = options.maxlength || _this.attr('maxlength'); // get allowed maxlength

                    if ($.browser.msie) _this.attr('maxlength', '9000000000000'); // In IE can't remove maxlength
                    else _this.removeAttr('maxlength'); // remove maxlength so user can continue typing

                    var updateUI = function() {
                        var currentLength = _this.val().length;
                        var percent = Math.min(currentLength / mlength, 1);
                        // set (filled) bar length
                        bar.css({ "width": (100 * percent) + "%" });
                        // set color
                        //bar.css({ "backgroundColor": options.getColor(percent) });
                        // update chars left
                        charsUsed.text(currentLength);
                        charsLeft.text(mlength - currentLength);
                        // disable 'submit' button
                        if (options.submit != null) {
                            var disabled = (mlength < currentLength);
                            options.submit.attr("jquery-wajbar-disabled", disabled);
                            if (options.disabler) options.disabler(options.submit, disabled);
                            else if (disabled) options.submit.attr("disabled", true);
                            else options.submit.removeAttr("disabled");
                        }
                        return true;
                    };

                    _this.keypress(updateUI);
                    _this.keyup(updateUI);
                    _this.change(function() { window.setTimeout(updateUI, 200); });

                    updateUI();

                    return barTemplate[0];
                }
            });
        }
    });
})(jQuery);