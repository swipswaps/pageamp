package pageamp.server;

import pageamp.web.DomTools.DomElement;
import pageamp.core.Element;
import pageamp.core.Node;
import pageamp.core.Page;

using pageamp.web.DomTools;

class Output {

	public static function write(page:Page) {

	}

	public static function toMarkup(page:Page): String {
		var root = page.doc.domRootElement();
		// 1. set logic ids
		addIds(page);
		// 2. add state descriptor
		// 3. add client code
		// 4. serialize DOM
		return root.domMarkup();
	}

	public static function addIds(p:Element) {
		for (n in p.children) {
			if (Std.is(n, Element)) {
				var e:Element = untyped n;
				var dom:DomElement = cast e.getDomNode();
				if (dom != null) {
					dom.domSet(Element.ID_DOM_ATTRIBUTE, e.id + '');
				}
				addIds(e);
			}
		}
	}

}
