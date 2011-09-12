(function($){
	$.extend({ 
		instedd: {
			init_components: function(container) {
				// initialize built-in components.
				if ($.fn.datepicker) {
					$(".ux-datepicker:not([readonly])", container)
						.click(function(){ $(this).datepicker("show"); })
						.datepicker();
				}

				$("input[type='text']", container).addClass("ux-text");
				$("input[type='password']", container).addClass("ux-text");
				$("input[type='email']", container).addClass("ux-text");
				$("textarea", container).addClass("ux-text");
				$(".ux-dropdown select", container).addClass("styled");
				$("input[type='radio']", container).addClass("styled");
				$("input[type='checkbox']", container).addClass("styled");

				$(".ux-wajbar", container).wajbar();

				$(".ux-nstep", container).each(function(){
					var nstep = $(this);
					var source = $("input[type='text']", nstep);
					var kdown = $("<button>").attr('type','button').addClass('kdown').text('');
					var kup = $("<button>").attr('type','button').addClass('kup').text('');
					nstep.append(kdown).append(kup);
					
					if (source.attr('readonly')) {
						// is readonly
						kdown.attr('disabled', true);
						kup.attr('disabled', true);
					} else {
						var current = function(){
							var res = parseInt(source.val());
							return isNaN(res) ? 0 : res;
						};
						kdown.click(function(){ source.val(current()-1); });
						kup.click(function(){ source.val(current()+1); });
					}
				});
				
				$("input[readonly='readonly'], textarea[readonly='readonly']", container).addClass("readonly");
				$("button[disabled]", container).addClass("disabled");
				
				Custom.init();
			}
		} 
	});
	
	$(function(){
		$.instedd.init_components($(document));
		
		$('.ux-collapsible > span:first-child > a').live('click', function(){
			var collapsible = $(this).closest('.ux-collapsible');
			collapsible.toggleClass('collapsed');
			
			if (collapsible.data('on-expanded')) {
				if (collapsible.hasClass('collapsed')) {
					collapsible.removeClass(collapsible.data('on-expanded'));
				} else {
					collapsible.addClass(collapsible.data('on-expanded'));
				}
			}
			
			return false;
		});
		
		// these are one time per page		
		// position user menu
		$('#User').mouseenter(function(){
			var container = $('.container', $(this));
			var band = $('.band', container);
			if (band.length == 0) {
				container.prepend(band = $("<div>").addClass("band"));
			}
			var margin_to_center = -container.width()/2 + $(this).width()/2 - 2;
			container.css('margin-left', margin_to_center);
			var exceeded = container.offset().left + container.width() - $(window).width() + 20; // HACK 20 a bit of space

			if (exceeded > 0) {
				container.css('margin-left', margin_to_center - $(this).width()/2 - exceeded - 10); // HACK padding of container
				band.css('margin-left',  container.width()/2 + exceeded);
			} else {
				band.css('margin-left', 'auto');
				band.css('margin-right', 'auto');
			}
			
			band.width($(this).width() + 20); // hack padding of #User
		});
		
		// add in the pre-last li of the BreadCrumb a span
		var bc_items = $('.BreadCrumb li');
		if (bc_items.length >= 2) {
			$(bc_items[bc_items.length - 2]).append($("<span>"));
		}
		//
		
		// add before/after for the NavMenu
		var nav_menu = $('#NavMenu ul');
		nav_menu.prepend($('<li>')).append($('<li>'));
		var active_item = $(".active", nav_menu);
		active_item.prev().addClass('before');
		active_item.next().addClass('after');
		//
	});
})(jQuery);