package pageamp.test2.core;

import haxe.unit.TestCase;
import pageamp.core.Element;
import pageamp.test2.core.NodeTest.TestNode;
import pageamp.util.PropertyTool;
import pageamp.web.DomTools;

using StringTools;
using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

//TODO: test event expressions
//TODO: test handler expressions
//TODO: test scripting API (see Element.makeScope())
class ElementTest extends TestCase {

	public function testInnerTextAttribute() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.INNERTEXT_PROP, '1<a');
		var p = new Element(root, props);

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">1&lt;a'
		+ '</body></html>', doc.domToString());
	}

	public function testInnerHtmlAttribute() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.INNERHTML_PROP, '<p>hi!</p>');
		var p = new Element(root, props);

		assertEquals('<html>'
		+ '<head></head><body data-pa="2"><p>hi!</p>'
		+ '</body></html>', doc.domToString());
	}

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

	function testClassAttribute1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.CLASS_PREFIX + 'class1', "${true}");
		var p = new Element(root, props);
		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body data-pa="2" class="class1">'
		+ '</body></html>', doc.domToString());

		p.set('c_class1', false);

		assertEquals('<html>'
		+ '<head></head><body data-pa="2" class="">'
		+ '</body></html>', doc.domToString());
	}

	function testStyleAttribute1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.STYLE_PREFIX + 'color', "red");
		var p = new Element(root, props);
		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body data-pa="2" style="color: red;">'
		+ '</body></html>', doc.domToString());

		p.set('s_color', null);

		assertEquals('<html>'
		+ '<head></head><body data-pa="2" style="">'
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
