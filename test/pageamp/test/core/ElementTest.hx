package pageamp.test.core;

import pageamp.util.PropertyTool;
import pageamp.test.core.NodeTest.TestNode;
import pageamp.core.Element;
import pageamp.web.DomTools;
import pageamp.util.Test;

using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

class ElementTest extends Test {

	function testDomAttribute() {
		DomTools.testDoc(null, function(doc:DomDocument, cleanup:Void->Void) {
			var root = new TestRootElement(doc);
			var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
			props.set(Element.ATTRIBUTE_PREFIX + 'id', 'my-id');
			var p = new Element(root, props);

			assert(doc.domToString(), '<html>'
			+ '<head></head><body id="my-id">'
			+ '</body></html>');

			cleanup();
			didDelay();
		});
	}

	function testClassAttribute2() {
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