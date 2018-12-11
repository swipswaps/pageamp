package pageamp.test.core;

import pageamp.core.Root;
import pageamp.core.Node;
import pageamp.util.Test;

class NodeTest extends Test {

	public function testNode1() {
		var n = new TestNode(null);
		assert(n.id, 1);
		assert(n.staticInits, 1);
		// root node always has its own scope
		assertNotNull(n.getScope(false));
		var n2 = new TestNode(n);
		assert(n2.id, 2);
		// TestNode type was inited already
		assert(n2.staticInits, 0);
		// static nodes don't have their own scope
		assertNull(n2.getScope(false));
		// but they inherit the outer one
		assertNotNull(n2.getScope());
	}

}

class TestNode extends Node implements Root {
	public var rootHelper = new RootHelper();
	public var staticInits = 0;

	public function typeInit(node:Node, cb:Void->Void): Void {
		rootHelper.typeInit(node, cb);
	}

	public function nextId(): Int {
		return rootHelper.nextId();
	}

	override public function staticInit() {
		staticInits++;
	}

}