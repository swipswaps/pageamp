package pageamp.test2.core;

import pageamp.core.Text;
import pageamp.core.Element;
import pageamp.test2.core.ElementTest.TestRootElement;
import pageamp.test2.core.ElementTest.TestDataProvider;
import haxe.unit.TestCase;
import pageamp.util.PropertyTool;

using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

class TextTest extends TestCase {

	function testText1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		var body = new Element(root, props);
		new Text(body, '1<a');

		assertEquals('<html>'
		+ '<head></head><body>1&lt;a'
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
		var p = new Element(root, props);
		new Text(p, "$data{text()}");
		root.refresh();

		assertEquals('<html>'
		+ '<head></head><body>Item 1'
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
		var r = new Element(p, props);
		new Text(r, "$data{text()}");

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

}
