package pageamp.test2.core;

import haxe.unit.TestCase;
import pageamp.core.Element;
import pageamp.test2.core.NodeTest.TestNode;
import pageamp.util.PropertyTool;
import pageamp.web.DomTools;

using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

class ElementTest extends TestCase {

	public function testDomAttribute1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.ATTRIBUTE_PREFIX + 'id', 'my-id');
		var p = new Element(root, props);

		assertEquals('<html>'
		+ '<head></head><body id="my-id">'
		+ '</body></html>', doc.domToString());
	}

	function testDomAttribute2() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.ATTRIBUTE_PREFIX + 'id', "${'my-id'}");
		var p = new Element(root, props);

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">'
		+ '</body></html>', doc.domToString());

		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body data-pa="2" id="my-id">'
		+ '</body></html>', doc.domToString());
	}

}

// =============================================================================
// TestRootElement
// =============================================================================

class TestRootElement extends TestNode {
	public var doc: DomDocument;
	public var body(get,null): DomElement;
	public inline function get_body(): DomElement return doc.domGetBody();

	public function new(doc:DomDocument) {
		this.doc = doc;
		super(null);
	}

	override public function createDomElement(tagname:String): DomElement {
		return doc.domCreateElement(tagname);
	}

}
