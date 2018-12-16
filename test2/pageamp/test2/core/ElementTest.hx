package pageamp.test2.core;

import pageamp.web.URL;
import pageamp.data.DataProvider;
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

	function testInnerTextAttribute() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.INNERTEXT_PROP, '1<a');
		var p = new Element(root, props);

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">1&lt;a'
		+ '</body></html>', doc.domToString());
	}

	function testInnerHtmlAttribute() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.INNERHTML_PROP, '<p>hi!</p>');
		var p = new Element(root, props);

		assertEquals('<html>'
		+ '<head></head><body data-pa="2"><p>hi!</p>'
		+ '</body></html>', doc.domToString());
	}

	function testDomAttribute1() {
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

	function testHidden1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.STYLE_PREFIX + 'color', "red");
		var p = new Element(root, props);
		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body data-pa="2" style="color: red;">'
		+ '</body></html>', doc.domToString());

		p.setHidden(true);

		assertEquals('<html>'
#if !client
		+ '<head></head><body data-pa="2" style="display: none;">'
#else
		+ '<head></head><body data-pa="2" style="color: red; display: none;">'
#end
		+ '</body></html>', doc.domToString());

		p.set('s_color', 'blue');

		assertEquals('<html>'
#if !client
		+ '<head></head><body data-pa="2" style="display: none;">'
#else
		+ '<head></head><body data-pa="2" style="color: blue; display: none;">'
#end
		+ '</body></html>', doc.domToString());

		p.setHidden(false);

		assertEquals('<html>'
		+ '<head></head><body data-pa="2" style="color: blue;">'
		+ '</body></html>', doc.domToString());

	}

	function testDatabinding1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		root.set('data1', new TestDataProvider('<root>
			<item id="1">Item 1</item>
			<item id="2">Item 2</item>
			<item id="3">Item 3</item>
		</root>'));
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.DATAPATH_PROP, 'data1:/root/item');
		props.set(Element.INNERTEXT_PROP, "$data{text()}");
		var p = new Element(root, props);
		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">Item 1'
		+ '</body></html>', doc.domToString());
	}

	function testDatabinding2() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		root.set('data1', new TestDataProvider('<root>
			<item id="1">Item 1</item>
			<item id="2">Item 2</item>
			<item id="3">Item 3</item>
		</root>'));
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.DATAPATH_PROP, 'data1:/root/item');
		props.set(Element.INNERTEXT_PROP, "$data{text()}");
		var p = new Element(root, props);
		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">Item 1'
		+ '</body></html>', doc.domToString());

		p.set(Element.DATAPATH_PROP, 'data1:/root/item[2]');

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">Item 2'
		+ '</body></html>', doc.domToString());
	}

	function testDatabinding3() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		root.set('data1', new TestDataProvider('<root>
			<item id="1">Item 1</item>
			<item id="2">Item 2</item>
			<item id="3">Item 3</item>
		</root>'));
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.DATAPATH_PROP, 'data1:/root/item');
		props.set(Element.INNERTEXT_PROP, "$data{text()}");
		var p = new Element(root, props);
		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">Item 1'
		+ '</body></html>', doc.domToString());

		p.set(Element.DATAPATH_PROP, 'data1:/root/item[2]');

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">Item 2'
		+ '</body></html>', doc.domToString());

		root.set('data1', new TestDataProvider('<root>
			<item id="1">Item A</item>
			<item id="2">Item B</item>
			<item id="3">Item C</item>
		</root>'));

		assertEquals('<html>'
		+ '<head></head><body data-pa="2">Item B'
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

class TestDataProvider implements DataProvider {
	public var doc: Xml;

	public function new(src:String) {
		doc = Xml.parse(src);
	}

	public function getData(?url:URL): Xml {
		return doc;
	}

	public function isRequesting(): Bool {
		return false;
	}

	public function abortRequest(): Void {
		// nop
	}

}