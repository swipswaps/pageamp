package pageamp.core;

import pageamp.web.DomTools;
import pageamp.util.ArrayTool;
import pageamp.util.PropertyTool;
import pageamp.web.ColorTools;
import pageamp.web.DomTools;

using StringTools;
using pageamp.util.ArrayTool;
using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

class Head extends Element {

	public function new(parent:Node, ?props:Props, ?cb:Dynamic->Void) {
		this.props = props = props.set(Element.NAME_PROP, 'head');
		super(parent, props, cb);
	}

	override function init() {
		var e = root.getDocument().domGetHead();
		e != null ? props = props.set(Element.ELEMENT_DOM, e) : null;
		Std.is(parent, Page) ? cast(parent, Page).head = this : null;
		super.init();
		initCssApi();
	}

	function makeShadow(x='0px', y='0px', radius='0px', col='#000') {
		//TODO: old IEs
		return '-moz-box-shadow:$x $y $radius $col;'
			+ '-webkit-box-shadow:$x $y $radius $col;'
			+ '-box-shadow:$x $y $radius $col;'
			+ 'box-shadow:$x $y $radius $col;';
	}

	function makeInsetShadow(x=0, y=0, r=4, col='#000') {
		return '-moz-box-shadow:${x}px ${y}px ${r}px $col inset;\n'
			+ '-webkit-box-shadow:${x}px ${y}px ${r}px $col inset;\n'
			+ '-box-shadow:${x}px ${y}px ${r}px $col inset;\n'
			+ 'box-shadow:${x}px ${y}px ${r}px $col inset';
	}

	// =========================================================================
	// CSS API
	// =========================================================================
	static inline var GOOGLE_FONT = 'https://fonts.googleapis.com/css?family=';
	var fonts = new Map<String,DomElement>();

	#if !debug inline #end
	function initCssApi() {

		set('cssVendorize', function(s:String) {
			return '$s;\n'
			+ '-moz-$s;\n'
			+ '-webkit-$s;\n'
			+ '-ms-$s;';
		});

		// e.g. cssGoogleFont('Lato:300,400,700') adds link and returns '"Lato"'
		set('cssGoogleFont', function(name:String) {
			if (!fonts.exists(name)) {
				var styles = DomTools.domGetElementsByTagName(dom, 'style');
				var before = ArrayTool.peek(untyped styles);
				var link = root.createDomElement('link', {
					rel: 'stylesheet',
					type: 'text/css',
					href: GOOGLE_FONT + name.split(' ').join('+'),
				}, dom, before);
				fonts.set(name, link);
			}
			return '"' + name.split(":")[0] + '"';
		}).unlink();

		set('cssMakeSelectable', function() {
			return '-webkit-touch-callout:text;'
			+ '-webkit-user-select:text;'
			+ '-khtml-user-select:text;'
			+ '-moz-user-select:text;'
			+ '-ms-user-select:text;'
			+ 'user-select:text;';
		}).unlink();

		set('cssMakeNonSelectable', function() {
			return '-webkit-touch-callout:none;'
			+ '-webkit-user-select:none;'
			+ '-khtml-user-select:none;'
			+ '-moz-user-select:none;'
			+ '-ms-user-select:none;'
			+ 'user-select:none;';
		}).unlink();

		// http://webdesignerwall.com/tutorials/cross-browser-css-gradient
		set('cssMakeVGradient', function(bg1, bg2) {
			bg1 = ColorTools.fullRgb(bg1);
			bg2 = ColorTools.fullRgb(bg2);
			return 'background-color:$bg1;'
			+ 'filter:progid:DXImageTransform.Microsoft.gradient'
			+ '(startColorstr=\'${bg1}\', endColorstr=\'${bg2}\');'
			+ 'background:-webkit-gradient(linear, left top,'
			+ ' left bottom, from($bg1), to($bg2));'
			+ 'background:-moz-linear-gradient(top, $bg1, $bg2);';
		}).unlink();

		// ...drop-shadow-with-css-for-all-web-browsers
		// https://tinyurl.com/yckn4rk
		set('cssMakeShadow', makeShadow).unlink();

		set('cssMakeInsetShadow', makeInsetShadow).unlink();

		set('cssFullRgb', ColorTools.fullRgb).unlink();
		set('cssColor2Components', ColorTools.color2Components).unlink();
		set('cssComponents2Color', ColorTools.components2Color).unlink();
		set('cssColorOffset', ColorTools.colorOffset).unlink();
		set('cssCounterColor', ColorTools.counterColor).unlink();
		set('cssColorMix', ColorTools.mix).unlink();

	}

}
