package pageamp.server;

import haxe.format.JsonPrinter;
import haxe.Json;
import pageamp.util.ArrayTool;
import pageamp.web.DomTools.DomTextNode;
import pageamp.core.Text;
import pageamp.core.Datasource;
import pageamp.util.PropertyTool;
import pageamp.web.DomTools.DomElement;
import pageamp.core.Element;
import pageamp.core.Page;

using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

class Output {

//	public static function write(page:Page) {
//
//	}
//
//	public static function toMarkup(page:Page): String {
//		var root = page.doc.domRootElement();
//		// 1. set logic ids
//		addIds(page);
//		// 2. add state descriptor
//		// 3. add client code
//		// 4. serialize DOM
//		return root.domMarkup();
//	}
//
//	public static function addIds(p:Element) {
//		for (n in p.children) {
//			if (Std.is(n, Element)) {
//				var e:Element = untyped n;
//				var dom:DomElement = cast e.getDomNode();
//				if (dom != null) {
//					dom.domSet(Element.ID_DOM_ATTRIBUTE, e.id + '');
//				}
//				addIds(e);
//			}
//		}
//	}

	public static function addClient(page:Page, ua:String) {
		function getChildren(props:Props): Array<Props> {
			var children:Array<Props> = props.get(Page.ISOCHILDREN_PROP);
			if (children == null) {
				props.set(Page.ISOCHILDREN_PROP, children = []);
			}
			return children;
		}
		var f = null;
		f = function(props:Props, t:Element) {
			var children1:Array<Props> = null;
			var scope = t.getScope();
			if (scope == null) {
				return;
			}
			//var extScope = (t.parent != null ? t.nodeParent.getScope() : null);
			if (scope.owner == t) {
				children1 == null ? children1 = getChildren(props) : null;
				t.dom.domSet(Element.ID_DOM_ATTRIBUTE, t.id + '');
				t.props.set(Element.ELEMENT_ID, t.id);
				t.props.remove(Element.ELEMENT_DOM);
				t.props.remove(Element.ELEMENT_TAG);

				//TODO: client shouldn't reload dynamic data we already store here
				if (Std.is(t, Datasource)) {
					var s = t.get(Datasource.DOC_VALUE, false);
					s != null ? t.dom.domSetInnerHTML(s) : null;
					t.props.remove(Datasource.XML_PROP);
					t.props.remove(Datasource.JSON_PROP);
				}

				children1.push(t.props);
				props = t.props;
			}
			var children2:Array<Props> = null;
			for (c in t.baseChildren) {
				if (Std.is(c, Element)) {
					f(props, untyped c);
				} else if (Std.is(c, Text)) {
					var text:Text = untyped c;
					var n:DomTextNode = untyped text.getDomNode();
					if (text.value != null) {
						var p = n.domGetParent();
						var s = text.id + '';
						var m = page.createDomElement('b',
								PropertyTool.set(null, Element.ID_DOM_ATTRIBUTE, s),
								p, n);
						var tp:Props = {};
						tp.set(Element.ID_DOM_ATTRIBUTE, text.id);
						tp.set(Text.TEXT_PROP, text.value.source);
						children2 == null ? children2 = getChildren(props) : null;
						children2.push(tp);
					}
				}
			}
		}
		var props:Props = {};
		f(props, page);
		var root = ArrayTool.peek(props.get(Page.ISOCHILDREN_PROP));
#if test
		var s = (root != null ? SortedJsonPrinter.print(root) : '{}');
#else
		var s = (root != null ? Json.stringify(root) : '{}');
#end
		var body = page.doc.domGetBody();
		s = Page.ISOPROPS_ID + ' = ' + s + ';';
		page.createDomElement('script', null, body).domSetInnerHTML(s);
		page.createDomTextNode('\n', body);
#if resizeMonitor
		var chromeVersion = .0;
		~/(Chrome\/\d+(\.\d+)?)/.map(ua, function(re:EReg) {
			var p = re.matchedPos();
			var s = ua.substr(p.pos, p.len).split('/')[1];
			chromeVersion = Std.parseFloat(s);
			return '';
		});
		if (chromeVersion < 64) {
			var src = Resource.getString("resize-observer.js");
			createDomElement('script', null, body).domSetInnerHTML(src);
			createDomTextNode('\n', body);
		}

		// https://philipwalton.com/articles/responsive-components-a-solution-to-the-container-queries-problem/
		s = ~/(\s{2,})/g.replace("(function() {
			var breakpoints = {SM:384, MD:576, LG:768, XL:960};
			function f(entries) {
				entries.forEach(function(entry) {
					var ub1 = entry.target.ub1;
					if (ub1) {
						ub1.set('resizeWidth', entry.contentRect.width);
						ub1.set('resizeHeight', entry.contentRect.height);
					}
					Object.keys(breakpoints).forEach(function(breakpoint) {
						var minWidth = breakpoints[breakpoint];
						if (entry.contentRect.width >= minWidth) {
							entry.target.classList.add(breakpoint);
						} else {
							entry.target.classList.remove(breakpoint);
						}
					});
				});
			}
			var ro = (ResizeObserver != null ? new ResizeObserver(f) : null);
			if (ro != null) {
				var l = document.querySelectorAll('[class~="+ RESIZE_CLASS +"]');
				for (var e, i = 0; e = l[i]; i++) ro.observe(e);
			}
			"+ RESIZE_OBSERVER +" = ro;
		})();", ' ');
		createDomElement('script', null, body).domSetInnerHTML(s);
		createDomTextNode('\n', body);
#end
		page.createDomElement('script', {
#if release
			src:'/.pageamp/client/bin/pageamp.min.js',
			async: 'async',
#else
			src:'/.pageamp/client/bin/pageamp.js',
#end
		}, body);
		page.createDomTextNode('\n', body);
	}

}

#if test
class SortedJsonPrinter extends JsonPrinter {

	static public function print(o:Dynamic, ?replacer:Dynamic -> Dynamic -> Dynamic, ?space:String) : String {
		var printer = new SortedJsonPrinter(replacer, space);
		printer.write("", o);
		return printer.buf.toString();
	}

	override function fieldsString( v : Dynamic, fields : Array<String> ) {
		super.fieldsString(v, ArrayTool.stringSort(fields));
	}

}
#end
