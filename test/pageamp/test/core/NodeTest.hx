package pageamp.test.core;

import pageamp.react.ValueContext;
import pageamp.core.Define;
import pageamp.web.DomTools;
import pageamp.util.BaseNode;
import pageamp.core.Root;
import haxe.unit.TestCase;
import pageamp.core.Node;
import pageamp.util.PropertyTool;

class NodeTest extends TestCase {

	public function testNodeId() {
		var n = new TestNode(null);
		assertEquals(1, n.id);
		var n2 = new TestNode(n);
		assertEquals(2, n2.id);
	}

	public function testNodeScope() {
		var n = new TestNode(null);
		// root node always has its own scope
		assertTrue(n.getScope(false) != null);
		var n2 = new TestNode(n);
		// static nodes don't have their own scope
		assertTrue(n2.getScope(false) == null);
		// but they inherit the outer one
		assertTrue(n2.getScope() != null);
	}

	public function testNodeInit() {
		var n = new TestNode(null);
		assertEquals(1, n.staticInits);
		var n2 = new TestNode(n);
		// TestNode type was inited already
		assertEquals(0, n2.staticInits);
	}

	public function testNodePlug() {
		var n1 = new TestNode(null);
		var n2 = new Node(n1);
		n1.getSlots().set('default', n2);
		var n3 = new Node(n1, PropertyTool.set(null, Node.NODE_PLUG, 'default'));
		// physical parent
		assertEquals(n2, n3.parent);
		// logical parent
		assertEquals(n1, cast n3.logicalParent);
	}

	public function testNodeIndex() {
		var n1 = new TestNode(null);
		var n2 = new Node(n1);
		assertEquals(0, n2.getIndex());
		var n3 = new Node(n1, PropertyTool.set(null, Node.NODE_INDEX, 0));
		assertEquals(0, n3.getIndex());
		assertEquals(1, n2.getIndex());
	}

	public function testNodeSlotIndex() {
		var n1 = new TestNode(null);
		var n2 = new Node(n1);
		n1.getSlots().set('default', n2);
		var n3 = new Node(n1);
		assertEquals(0, n3.getIndex());
		var n4 = new Node(n1, PropertyTool.set(null, Node.NODE_INDEX, 0));
		assertEquals(0, n4.getIndex());
		assertEquals(1, n3.getIndex());
	}

}

// =============================================================================
// TestNode
// =============================================================================


class TestNode extends Node implements Root {
	public var rootHelper = new RootHelper(null);
	public var staticInits = 0;
	public var defines = new Map<String, Define>();

	public function getSlots() {
		slots == null ? slots = new Map<String, BaseNode>() : null;
		return slots;
	}

	override public function staticInit() {
		staticInits++;
	}

	// =========================================================================
	// as Root
	// =========================================================================

	public function typeInit(node:Node, cb:Void->Void): Void {
		rootHelper.typeInit(node, cb);
	}

	public function nextId(): Int {
		return rootHelper.nextId();
	}

	public function createDomElement(tagname:String): DomElement {
		return rootHelper.createDomElement(tagname);
	}

	public function createDomTextNode(text:String): DomTextNode {
		return rootHelper.createDomTextNode(text);
	}

	public function getDefine(name:String): Define {
		return rootHelper.getDefine(name);
	}

	public function setDefine(name:String, def:Define): Void {
		rootHelper.setDefine(name, def);
	}

	public function getComputedStyle(name:String, ?pseudoElt:String): String {
		return rootHelper.getComputedStyle(name, pseudoElt);
	}

	public function getContext(): ValueContext {
		return scope.context;
	}

}
