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
		var root = doc.getRoot();
		assertTrue(Std.is(root, SrcElement));
		var text = root.nthNode(0);
		assertTrue(Std.is(text, SrcText));
	}

	function testNodePos1() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<:tag>some text</:tag>');
		var root:SrcElement = doc.getRoot();
		var pos = root.getPos();
		assertEquals(1, pos.line);
		assertEquals(1, pos.column);
		assertEquals(6, pos.length);
		var text:SrcText = root.nthNode(0);
		pos = text.getPos();
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
		var root:SrcElement = doc.getRoot();
		var pos = root.getPos();
		assertEquals(1, pos.line);
		assertEquals(1, pos.column);
		assertEquals(7, pos.length);
		var text:SrcText = root.nthNode(0);
		pos = text.getPos();
		assertEquals(2, pos.line);
		assertEquals(2, pos.column);
		assertEquals(14, pos.length);
	}

	function testNodePos3() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc(''
		+ '<root a="v1"\n'
		+ '      b="v2"/>');
		var root = doc.getRoot();
		var a1:SrcAttribute = root.nthAttribute(0);
		assertTrue(Std.is(a1, SrcAttribute));
		assertEquals(a1.name, 'a');
		var p1 = a1.getPos();
		assertEquals(1, p1.line);
		assertEquals(7, p1.column);
		var a2:SrcAttribute = root.nthAttribute(1);
		assertTrue(Std.is(a2, SrcAttribute));
		assertEquals(a2.name, 'b');
		var p2 = a2.getPos();
		assertEquals(2, p2.line);
		assertEquals(7, p2.column);
	}

	function testNodePos4() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<root>\n'
		+ '<element a="v1"\n'
		+ '    b="v2"/>\n'
		+ '</root>');
		var root = doc.getRoot();
		var element = root.nthElement(0);
		var a1:SrcAttribute = element.nthAttribute(0);
		assertTrue(Std.is(a1, SrcAttribute));
		assertEquals(a1.name, 'a');
		var p1 = a1.getPos();
		assertEquals(2, p1.line);
		assertEquals(10, p1.column);
		var a2:SrcAttribute = element.nthAttribute(1);
		assertTrue(Std.is(a2, SrcAttribute));
		assertEquals(a2.name, 'b');
		var p2 = a2.getPos();
		assertEquals(3, p2.line);
		assertEquals(5, p2.column);
	}

}
