package pageamp.test2.core;

import pageamp.web.DomTools.DomElement;
import pageamp.util.BaseNode;
import pageamp.util.PropertyTool;
import pageamp.core.Root;
import pageamp.core.Node;
import pageamp.util.Test;

class NodeTest extends Test {

	public function testNodeId() {
		var n = new TestNode(null);
		assert(n.id, 1);
		var n2 = new TestNode(n);
		assert(n2.id, 2);
	}

	public function testNodeScope() {
		var n = new TestNode(null);
		// root node always has its own scope
		assertNotNull(n.getScope(false));
		var n2 = new TestNode(n);
		// static nodes don't have their own scope
		assertNull(n2.getScope(false));
		// but they inherit the outer one
		assertNotNull(n2.getScope());
	}

	public function testNodeInit() {
		var n = new TestNode(null);
		assert(n.staticInits, 1);
		var n2 = new TestNode(n);
		// TestNode type was inited already
		assert(n2.staticInits, 0);
	}

	public function testNodePlug() {
		var n1 = new TestNode(null);
		var n2 = new Node(n1);
		n1.getSlots().set('default', n2);
		var n3 = new Node(n1, PropertyTool.set(null, Node.NODE_PLUG, 'default'));
		// physical parent
		assert(n3.parent, n2);
		// logical parent
		assert(n3.logicalParent, n1);
	}

	public function testNodeIndex() {
		var n1 = new TestNode(null);
		var n2 = new Node(n1);
		assert(n2.getIndex(), 0);
		var n3 = new Node(n1, PropertyTool.set(null, Node.NODE_INDEX, 0));
		assert(n3.getIndex(), 0);
		assert(n2.getIndex(), 1);
	}

	public function testNodeSlotIndex() {
		var n1 = new TestNode(null);
		var n2 = new Node(n1);
		n1.getSlots().set('default', n2);
		var n3 = new Node(n1);
		assert(n3.getIndex(), 0);
		var n4 = new Node(n1, PropertyTool.set(null, Node.NODE_INDEX, 0));
		assert(n4.getIndex(), 0);
		assert(n3.getIndex(), 1);
	}

}

// =============================================================================
// TestNode
// =============================================================================

class TestNode extends Node implements Root {
	public var rootHelper = new RootHelper();
	public var staticInits = 0;

	public function typeInit(node:Node, cb:Void->Void): Void {
		rootHelper.typeInit(node, cb);
	}

	public function nextId(): Int {
		return rootHelper.nextId();
	}

	public function getSlots() {
		slots == null ? slots = new Map<String, BaseNode>() : null;
		return slots;
	}

	override public function staticInit() {
		staticInits++;
	}

	public function createDomElement(tagname:String): DomElement {
		return null;
	}

	public function getComputedStyle(name:String, ?pseudoElt:String): String {
		return '';
	}

}
