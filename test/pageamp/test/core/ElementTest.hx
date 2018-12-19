package pageamp.test.core;

import pageamp.web.URL;
import pageamp.data.DataProvider;
import haxe.unit.TestCase;
import pageamp.core.Element;
import pageamp.test.core.NodeTest.TestNode;
import pageamp.util.PropertyTool;
import pageamp.web.DomTools;

using StringTools;
using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

//TODO: test event expressions
//TODO: test handler expressions
//TODO: test scripting API (see Element.makeScope())
@:access(pageamp.core.Element)
class ElementTest extends TestCase {

	function testInnerTextAttribute() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.INNERTEXT_PROP, '1<a');
		var p = new Element(root, props);

		assertEquals('<html>'
		+ '<head></head><body>1&lt;a'
		+ '</body></html>', doc.domToString());
	}

	function testInnerHtmlAttribute() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.INNERHTML_PROP, '<p>hi!</p>');
		var p = new Element(root, props);

		assertEquals('<html>'
		+ '<head></head><body><p>hi!</p>'
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
		+ '<head></head><body>'
		+ '</body></html>', doc.domToString());

		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body id="my-id">'
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
		+ '<head></head><body class="class1">'
		+ '</body></html>', doc.domToString());

		p.set('c_class1', false);

		assertEquals('<html>'
		+ '<head></head><body class="">'
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
		+ '<head></head><body style="color: red;">'
		+ '</body></html>', doc.domToString());

		p.set('s_color', null);

		assertEquals('<html>'
		+ '<head></head><body style="">'
		+ '</body></html>', doc.domToString());
	}

	function testMakeDomElement1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		var p = new Element(root, props);
		new Element(p);

		assertEquals('<html>'
		+ '<head></head><body><div></div>'
		+ '</body></html>', doc.domToString());

		props = PropertyTool.set(null, Element.ELEMENT_TAG, 'p');
		new Element(p, props);

		assertEquals('<html>'
		+ '<head></head><body><div></div><p></p>'
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
		+ '<head></head><body style="color: red;">'
		+ '</body></html>', doc.domToString());

		p.setHidden(true);

		assertEquals('<html>'
#if !client
		+ '<head></head><body style="display: none;">'
#else
		+ '<head></head><body style="color: red; display: none;">'
#end
		+ '</body></html>', doc.domToString());

		p.set('s_color', 'blue');

		assertEquals('<html>'
#if !client
		+ '<head></head><body style="display: none;">'
#else
		+ '<head></head><body style="color: blue; display: none;">'
#end
		+ '</body></html>', doc.domToString());

		p.setHidden(false);

		assertEquals('<html>'
		+ '<head></head><body style="color: blue;">'
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
		+ '<head></head><body>Item 1'
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
		+ '<head></head><body>Item 1'
		+ '</body></html>', doc.domToString());

		p.set(Element.DATAPATH_PROP, 'data1:/root/item[2]');

		assertEquals('<html>'
		+ '<head></head><body>Item 2'
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
		+ '<head></head><body>Item 1'
		+ '</body></html>', doc.domToString());

		p.set(Element.DATAPATH_PROP, 'data1:/root/item[2]');

		assertEquals('<html>'
		+ '<head></head><body>Item 2'
		+ '</body></html>', doc.domToString());

		root.set('data1', new TestDataProvider('<root>
			<item id="1">Item A</item>
			<item id="2">Item B</item>
			<item id="3">Item C</item>
		</root>'));

		assertEquals('<html>'
		+ '<head></head><body>Item B'
		+ '</body></html>', doc.domToString());
	}

	function testDatabinding4() {
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
		+ '<head></head><body>Item 1'
		+ '</body></html>', doc.domToString());

		p.set(Element.DATAPATH_PROP, 'data1:/root/item[10]');

		assertEquals('<html>'
		+ '<head></head><body style="display: none;">'
		+ '</body></html>', doc.domToString());

		p.set(Element.DATAPATH_PROP, 'data1:/root/item[2]');

		assertEquals('<html>'
#if !client
		+ '<head></head><body>Item 2'
#else
		+ '<head></head><body style="">Item 2'
#end
		+ '</body></html>', doc.domToString());
	}

	function testReplication1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		root.set('data1', new TestDataProvider('<root>
			<item id="1">Item 1</item>
			<item id="2">Item 2</item>
			<item id="3">Item 3</item>
		</root>'));
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.DATAPATH_PROP, 'data1:/root');
		var p = new Element(root, props);
		props = PropertyTool.set(null, Element.FOREACH_PROP, 'item');
		props.set(Element.INNERTEXT_PROP, "$data{text()}");
		var r = new Element(p, props);

		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<div style="display: none;"></div>'
		+ '</body></html>', doc.domToString());

		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<div style="display: none;"></div>'
		+ '<div>Item 1</div>'
		+ '<div>Item 2</div>'
		+ '<div>Item 3</div>'
		+ '</body></html>', doc.domToString());
	}

	function testReplication2() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		root.set('data1', new TestDataProvider('<root>
			<item id="1">Item 1</item>
			<item id="2">Item 2</item>
			<item id="3">Item 3</item>
		</root>'));
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.DATAPATH_PROP, 'data1:/root');
		var p = new Element(root, props);
		props = PropertyTool.set(null, Element.FOREACH_PROP, 'item');
		var r = new Element(p, props);
		props = PropertyTool.set(null, Element.INNERTEXT_PROP, "$data{text()}");
		props.set('a_id', "$data{@id}");
		new Element(r, props);

		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<div style="display: none;"><div></div></div>'
		+ '</body></html>', doc.domToString());

		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<div style="display: none;"><div></div></div>'
		+ '<div><div id="1">Item 1</div></div>'
		+ '<div><div id="2">Item 2</div></div>'
		+ '<div><div id="3">Item 3</div></div>'
		+ '</body></html>', doc.domToString());
	}

	function testNestedReplication1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		root.set('data1', new TestDataProvider('<root>
			<item id="1">Item 1</item>
			<item id="2">Item 2</item>
			<item id="3">Item 3</item>
		</root>'));
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		props.set(Element.DATAPATH_PROP, 'data1:/root');
		var body = new Element(root, props);
		props = PropertyTool.set(null, Element.FOREACH_PROP, 'item');
		var rep1 = new Element(body, props);
		props = PropertyTool.set(null, Element.FOREACH_PROP, 'data1:/root/item');
		var rep2 = new Element(rep1, props);
		props = PropertyTool.set(null, Element.INNERTEXT_PROP, "$data{text()}");
		props.set('a_id', "$data{@id}");
		new Element(rep2, props);

		assertEquals('<html><head></head><body>'
		+ '<div style="display: none;">'
			+ '<div style="display: none;">'
				+ '<div></div>'
			+ '</div>'
		+ '</div>'
		+ '</body></html>', doc.domToString());

		root.refresh();

		assertEquals('<html><head></head><body>'
		+ '<div style="display: none;">'
			+ '<div style="display: none;"><div></div></div>'
			+ '<div><div></div></div>'
			+ '<div><div></div></div>'
			+ '<div><div></div></div>'
		+ '</div>'
		+ '<div>'
			+ '<div style="display: none;"><div></div></div>'
			+ '<div><div id="1">Item 1</div></div>'
			+ '<div><div id="2">Item 2</div></div>'
			+ '<div><div id="3">Item 3</div></div>'
		+ '</div>'
		+ '<div>'
			+ '<div style="display: none;"><div></div></div>'
			+ '<div><div id="1">Item 1</div></div>'
			+ '<div><div id="2">Item 2</div></div>'
			+ '<div><div id="3">Item 3</div></div>'
		+ '</div>'
		+ '<div>'
			+ '<div style="display: none;"><div></div></div>'
			+ '<div><div id="1">Item 1</div></div>'
			+ '<div><div id="2">Item 2</div></div>'
			+ '<div><div id="3">Item 3</div></div>'
		+ '</div>'
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

	override
	public function getDocument(): DomDocument {
		return doc;
	}

	override
	public function createDomElement(name:String,
	                                 ?props:Props,
	                                 ?parent:DomElement,
	                                 ?before:DomNode): DomElement {
		var ret = doc.domCreateElement(name);
		for (k in props.keys()) {
			var v = props.get(k);
			v != null ? ret.domSet(k, Std.string(v)) : null;
		}
		parent != null ? parent.domAddChild(ret, before) : null;
		return ret;
	}

	override public function createDomTextNode(text:String): DomTextNode {
		return doc.domCreateTextNode(text);
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