(function($){
	$.extend({ 
		instedd: {
			init_components: function(container) {
				// initialize built-in components.
				if ($.fn.datepicker) {
					$(".ux-datepicker", container)
						.click(function(){ $(this).datepicker("show"); })
						.datepicker();
				}

				$("input[type='text']", container).addClass("ux-text");
				$("input[type='password']", container).addClass("ux-text");
				$("input[type='email']", container).addClass("ux-text");
				$("textarea", container).addClass("ux-text");
				$("input[readonly='readonly'], textarea[readonly='readonly']", container).addClass("readonly");
				$(".ux-dropdown select", container).addClass("styled");
				$("input[type='radio']", container).addClass("styled");
				$("input[type='checkbox']", container).addClass("styled");
				$("button[disabled]", container).addClass("disabled");

				$(".ux-wajbar", container).wajbar();

				$(".ux-nstep", container).each(function(){
					var nstep = $(this);
					var source = $("input[type='text']", nstep);
					var kdown = $("<input>").attr('type','button').addClass('kdown').val('');
					var kup = $("<input>").attr('type','button').addClass('kup').val('');
					nstep.append(kdown).append(kup);
					var current = function(){
						var res = parseInt(source.val());
						return isNaN(res) ? 0 : res;
					};
					kdown.click(function(){ source.val(current()-1); });
					kup.click(function(){ source.val(current()+1); });
				});
				
				Custom.init();
			}
		} 
	});
	
	$(function(){
		$.instedd.init_components($(document));
		
		// these are one time per page		
		// position user menu
		$('#User').mouseenter(function(){
			var container = $('.container', $(this));
			container.prepend($("<div>").addClass("band"));
			container.css('margin-left', -container.width()/2 + $(this).width()/2 - 2);
			$('.band', container).width($(this).width() + 20); // hack padding of #User
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