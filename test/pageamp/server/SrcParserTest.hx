package pageamp.server;

import htmlparser.HtmlParser;
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

	function testNodePos3() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc(''
		+ '<root a="v1"\n'
		+ '      b="v2"/>');
		var root = doc.children[0];
		var a1 = root.attributes[0];
		assertTrue(Std.is(a1, SrcAttribute));
		assertEquals(a1.name, 'a');
		var p1 = doc.getPos(a1);
		assertEquals(1, p1.line);
		assertEquals(7, p1.column);
		var a2 = root.attributes[1];
		assertTrue(Std.is(a2, SrcAttribute));
		assertEquals(a2.name, 'b');
		var p2 = doc.getPos(a2);
		assertEquals(2, p2.line);
		assertEquals(7, p2.column);
	}

	function testNodePos4() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<root>\n'
		+ '<element a="v1"\n'
		+ '    b="v2"/>\n'
		+ '</root>');
		var root = doc.children[0];
		var element = root.children[0];
		var a1 = element.attributes[0];
		assertTrue(Std.is(a1, SrcAttribute));
		assertEquals(a1.name, 'a');
		var p1 = doc.getPos(a1);
		assertEquals(2, p1.line);
		assertEquals(10, p1.column);
		var a2 = element.attributes[1];
		assertTrue(Std.is(a2, SrcAttribute));
		assertEquals(a2.name, 'b');
		var p2 = doc.getPos(a2);
		assertEquals(3, p2.line);
		assertEquals(5, p2.column);
	}

}
