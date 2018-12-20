package pageamp.server;

import htmlparser.HtmlNodeElement;
import pageamp.core.Datasource;
import pageamp.core.Define;
import pageamp.core.Element;
import pageamp.util.PropertyTool;

using StringTools;
using pageamp.util.PropertyTool;

class LoaderHelper {

	public static function loadDataProps(e:HtmlNodeElement, ?p:Props): Props {
		// 1. turn possible <xml> or <json> child elements into
		// element attributes
		var ee = new Array<HtmlNodeElement>();
		for (child in e.children.iterator()) {
			if (child.name == 'xml') {
				p = p.set(Datasource.XML_PROP, child.innerHTML);
				ee.push(child);
			} else if (child.name == 'json') {
				p = p.set(Datasource.JSON_PROP, child.innerText);
				ee.push(child);
			}
		}
		// 2. remove them
		while (ee.length > 0) {
			e.removeChild(ee.pop());
		}
		return p;
	}

	public static function loadDefineProps(p:Props): Props {
		var tagname = p.getString(Define.TAG_PROP, '');
		var parts = tagname.split(':');
		var name1 = parts.length > 0 ? parts[0].trim() : '';
		var name2 = parts.length > 1 ? parts[1].trim() : '';
		~/^([a-zA-Z0-9_\-]+)$/.match(name1) ? null : name1 = '_';
		~/^([a-zA-Z0-9_\-]+)$/.match(name2) ? null : name2 = 'div';
		p.remove(Define.TAG_PROP);
		p.remove(Element.ELEMENT_TAG);
		p = p.set(Define.DEFNAME_PROP, name1);
		p = p.set(Define.EXTNAME_PROP, name2);
		return p;
	}

}
