/*

CUSTOM FORM ELEMENTS

Created by Ryan Fait
www.ryanfait.com

The only things you may need to change in this file are the following
variables: checkboxHeight, radioHeight and selectWidth (lines 24, 25, 26)

The numbers you set for checkboxHeight and radioHeight should be one quarter
of the total height of the image want to use for checkboxes and radio
buttons. Both images should contain the four stages of both inputs stacked
on top of each other in this order: unchecked, unchecked-clicked, checked,
checked-clicked.

You may need to adjust your images a bit if there is a slight vertical
movement during the different stages of the button activation.

The value of selectWidth should be the width of your select list image.

Visit http://ryanfait.com/ for more information.

*/

var checkboxHeight = "25";
var radioHeight = "25";
/*var selectWidth = "312";*/

var cfePositions = {
	'checkbox': {
		'on': '-20px 0px',
		'on_hover': '-20px -20px',
		'on_active': '0px -40px',
		'off': '0px 0px',
		'off_hover': '0px -20px',
		'off_active': '-20px -40px'
	},
	'radio': {
		'on': '-20px 0px',
		'on_hover': '-20px -20px',
		'on_active': '0px -40px',
		'off': '0px 0px',
		'off_hover': '0px -20px',
		'off_active': '-20px -40px'
	}
};

/* No need to change anything after this */


document.write('<style type="text/css">input.styled { display: none; } select.styled { position: relative; ' + /*width: ' + selectWidth + 'px;*/ 'opacity: 0; filter: alpha(opacity=0); z-index: 5; } .disabled { opacity: 0.5; filter: alpha(opacity=50); }</style>');

function hasStyledClass(domElem) {
	return domElem.className.match(/\bstyled\b/)
}

var Custom = {
	init: function() {
		var inputs = document.getElementsByTagName("input"), span = Array(), textnode, option, active;
		for(a = 0; a < inputs.length; a++) {
			if((inputs[a].type == "checkbox" || inputs[a].type == "radio") && hasStyledClass(inputs[a])) {
				span[a] = document.createElement("span");
				span[a].className = inputs[a].type;

				if(inputs[a].checked == true) {
					span[a].style.backgroundPosition = cfePositions[inputs[a].type]['on'];
				} else {
					span[a].style.backgroundPosition = cfePositions[inputs[a].type]['off'];
				}
				inputs[a].parentNode.insertBefore(span[a], inputs[a]);
				inputs[a].onchange = Custom.clear;
				if(!inputs[a].getAttribute("disabled")) {
					span[a].onmousedown = Custom.pushed;
					span[a].onmouseup = Custom.check;
					jQuery(span[a]).hover(function(){
						element = this.nextSibling;
						if(element.checked == true) {
							this.style.backgroundPosition = cfePositions[element.type]['on_hover'];
						} else if(element.checked != true) {
							this.style.backgroundPosition = cfePositions[element.type]['off_hover'];
						}
					}, function(){
						element = this.nextSibling;
						if(element.checked == true) {
							this.style.backgroundPosition = cfePositions[element.type]['on'];
						} else if(element.checked != true) {
							this.style.backgroundPosition = cfePositions[element.type]['off'];
						}
					});
				} else {
					span[a].className = span[a].className += " disabled";
				}
				
				if (inputs[a].type == "checkbox") {
					span[a].id = "checkbox" + inputs[a].name;
				}
			}
		}
		inputs = document.getElementsByTagName("select");
		for(a = 0; a < inputs.length; a++) {
			if(hasStyledClass(inputs[a])) {
				option = inputs[a].getElementsByTagName("option");
				active = option[0].childNodes[0].nodeValue;
				textnode = document.createTextNode(active);
				for(b = 0; b < option.length; b++) {
					if(option[b].selected == true) {
						textnode = document.createTextNode(option[b].childNodes[0].nodeValue);
					}
				}
				span[a] = document.createElement("span");
				span[a].className = "select";
				span[a].id = "select" + inputs[a].name;
				span[a].appendChild(textnode);
				inputs[a].parentNode.insertBefore(span[a], inputs[a]);

				// begin InSTEDD: in order to have rounded beginning of dropdowns 
				var prefixSpan = document.createElement("span");
				prefixSpan.className = "selectPrefix";
				prefixSpan.id = "selectPrefix" + inputs[a].name;
				span[a].parentNode.insertBefore(prefixSpan, span[a]);
				// end
				
				// TODO should add prefix width to selct element to be 100% exact or use right padding/margin to remove from .select
				
				if(!inputs[a].getAttribute("disabled")) {
					inputs[a].onchange = Custom.choose;
				} else {
					inputs[a].previousSibling.className = inputs[a].previousSibling.className += " disabled";
					prefixSpan.className = prefixSpan.className + " disabled";
				}
			}
		}
		document.onmouseup = Custom.clear;
	},
	pushed: function() {
		element = this.nextSibling;
		if(element.checked == true) {
			this.style.backgroundPosition = cfePositions[element.type]['off_active'];
		} else if(element.checked != true) {
			this.style.backgroundPosition = cfePositions[element.type]['on_active'];
		}
	},
	check: function() {
		element = this.nextSibling;
		if(element.checked == true && element.type == "checkbox") {
			this.style.backgroundPosition = cfePositions[element.type]['off'];
			element.checked = false;
		} else {
			if(element.type == "checkbox") {
				this.style.backgroundPosition = cfePositions[element.type]['on'];
			} else {
				this.style.backgroundPosition = cfePositions[element.type]['on'];
				group = this.nextSibling.name;
				inputs = document.getElementsByTagName("input");
				for(a = 0; a < inputs.length; a++) {
					if(inputs[a].name == group && inputs[a] != this.nextSibling) {
						inputs[a].previousSibling.style.backgroundPosition = cfePositions[element.type]['off'];
					}
				}
			}
			element.checked = true;
			jQuery(element).change();
		}
	},
	clear: function() {
		inputs = document.getElementsByTagName("input");
		for(var b = 0; b < inputs.length; b++) {
			if(inputs[b].type == "checkbox" && inputs[b].checked == true && hasStyledClass(inputs[b])) {
				inputs[b].previousSibling.style.backgroundPosition = cfePositions[inputs[b].type]['on'];
			} else if(inputs[b].type == "checkbox" && hasStyledClass(inputs[b])) {
				inputs[b].previousSibling.style.backgroundPosition = cfePositions[inputs[b].type]['off'];
			} else if(inputs[b].type == "radio" && inputs[b].checked == true && hasStyledClass(inputs[b])) {
				inputs[b].previousSibling.style.backgroundPosition = cfePositions[inputs[b].type]['on'];
			} else if(inputs[b].type == "radio" && hasStyledClass(inputs[b])) {
				inputs[b].previousSibling.style.backgroundPosition = cfePositions[inputs[b].type]['off'];
			}
		}
	},
	choose: function() {
		option = this.getElementsByTagName("option");
		for(d = 0; d < option.length; d++) {
			if(option[d].selected == true) {
				document.getElementById("select" + this.name).childNodes[0].nodeValue = option[d].childNodes[0].nodeValue;
			}
		}
	}
}
window.onload = Custom.init;