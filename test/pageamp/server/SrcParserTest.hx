package pageamp.server;

import pageamp.server.SrcParser;
import haxe.unit.TestCase;

class SrcParserTest extends TestCase {

	function testColumnTag() {
		var doc = SrcParser.parseDoc('<:tag></:tag>');
		assertEquals('<:tag />', doc.toString());
	}

	function testNodeType1() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<:tag>some text</:tag>');
		assertTrue(Std.is(doc, SrcDocument));
		var root = doc.children[0];
		assertTrue(Std.is(root, SrcElement));
		var text = root.nodes[0];
		assertTrue(Std.is(text, SrcText));
	}

	function testNodePos1() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<:tag>some text</:tag>');
		var root = doc.children[0];
		var pos = doc.getPos(root);
		assertEquals(1, pos.line);
		assertEquals(1, pos.column);
		assertEquals(6, pos.length);
		var text = root.nodes[0];
		pos = doc.getPos(text);
		assertEquals(1, pos.line);
		assertEquals(7, pos.column);
		assertEquals(9, pos.length);
	}

	function testNodePos2() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc(''
		+ '<root\n'
		+ '>    some text\n'
		+ '</root>');
		var root = doc.children[0];
		var pos = doc.getPos(root);
		assertEquals(1, pos.line);
		assertEquals(1, pos.column);
		assertEquals(7, pos.length);
		var text = root.nodes[0];
		pos = doc.getPos(text);
		assertEquals(2, pos.line);
		assertEquals(2, pos.column);
		assertEquals(14, pos.length);
	}

}
