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
		+ '      b="v22" c/>');
		var root = doc.getRoot();
		var a1:SrcAttribute = root.nthAttribute(0);
		assertTrue(Std.is(a1, SrcAttribute));
		assertEquals(a1.name, 'a');
		var p1 = a1.getPos();
		assertEquals(1, p1.line);
		assertEquals(7, p1.column);
		assertEquals(6, p1.length);
		var a2:SrcAttribute = root.nthAttribute(1);
		assertTrue(Std.is(a2, SrcAttribute));
		assertEquals(a2.name, 'b');
		var p2 = a2.getPos();
		assertEquals(2, p2.line);
		assertEquals(7, p2.column);
		assertEquals(7, p2.length);
		var a3:SrcAttribute = root.nthAttribute(2);
		assertTrue(Std.is(a3, SrcAttribute));
		assertEquals(a3.name, 'c');
		var p3 = a3.getPos();
		assertEquals(2, p3.line);
		assertEquals(15, p3.column);
		assertEquals(1, p3.length);
	}

	function testNodePos4() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<root>\n'
		+ '<element a="v1"\n'
		+ '    b="v22" c/>\n'
		+ '</root>');
		var root = doc.getRoot();
		var element = root.nthElement(0);
		var a1:SrcAttribute = element.nthAttribute(0);
		var p1 = a1.getPos();
		assertEquals(2, p1.line);
		assertEquals(10, p1.column);
		assertEquals(6, p1.length);
		var a2:SrcAttribute = element.nthAttribute(1);
		var p2 = a2.getPos();
		assertEquals(3, p2.line);
		assertEquals(5, p2.column);
		assertEquals(7, p2.length);
		var a3:SrcAttribute = element.nthAttribute(2);
		var p3 = a3.getPos();
		assertEquals(3, p3.line);
		assertEquals(13, p3.column);
		assertEquals(1, p3.length);
	}

	function testTextPos1() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<root>\n'
		+ '  <element>\n'
		+ '    a sample text\n'
		+ '  </element>\n'
		+ '</root>');
		var root = doc.getRoot();
		var element = root.nthElement(0);
		var text = element.nthNode(0);
		var pos = text.getPos();
		assertEquals(2, pos.line);
		assertEquals(12, pos.column);
		assertEquals(21, pos.length);
		var i = text.text.indexOf('sample');
		pos = text.getPos(i);
		assertEquals(3, pos.line);
		assertEquals(7, pos.column);
		assertEquals(14, pos.length);
	}

	function testAttributePos1() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<root>\n'
		+ '<element a="v1"\n'
		+ '    b="v22" c/>\n'
		+ '</root>');
		var root = doc.getRoot();
		var element = root.nthElement(0);

		// whole attribute clause
		var a:SrcAttribute = element.nthAttribute(0);
		var p = a.getPos();
		assertEquals(2, p.line);
		assertEquals(10, p.column);
		assertEquals(6, p.length);
		// position in attribute value
		p = a.getPos(0);
		assertEquals(2, p.line);
		assertEquals(13, p.column);
		assertEquals(2, p.length);
		p = a.getPos(1);
		assertEquals(2, p.line);
		assertEquals(14, p.column);
		assertEquals(1, p.length);
		p = a.getPos(2);
		assertEquals(2, p.line);
		assertEquals(15, p.column);
		assertEquals(0, p.length);

		// whole attribute clause
		a = element.nthAttribute(1);
		p = a.getPos();
		assertEquals(3, p.line);
		assertEquals(5, p.column);
		assertEquals(7, p.length);
		// position in attribute value
		p = a.getPos(0);
		assertEquals(3, p.line);
		assertEquals(8, p.column);
		assertEquals(3, p.length);
		p = a.getPos(1);
		assertEquals(3, p.line);
		assertEquals(9, p.column);
		assertEquals(2, p.length);

		// whole attribute clause
		a = element.nthAttribute(2);
		p = a.getPos();
		assertEquals(3, p.line);
		assertEquals(13, p.column);
		assertEquals(1, p.length);
		// position in attribute value
		p = a.getPos(0);
		assertEquals(3, p.line);
		assertEquals(14, p.column);
		assertEquals(0, p.length);
	}

	function testAttributePos2() {
		var parser = new SrcParser();
		var doc:SrcDocument = SrcParser.parseDoc('<root>\n'
		+ '<element a="function() {\n'
		+ '    a = 2;\n'
		+ '}"/>\n'
		+ '</root>');
		var root = doc.getRoot();
		var element = root.nthElement(0);

		// whole attribute clause
		var a:SrcAttribute = element.nthAttribute(0);
		var p = a.getPos();
		assertEquals(2, p.line);
		assertEquals(10, p.column);
		assertEquals(29, p.length);
		// position in attribute value
		p = a.getPos(0);
		assertEquals(2, p.line);
		assertEquals(13, p.column);
		assertEquals(25, p.length);
		var offset = a.value.indexOf('=');
		p = a.getPos(offset);
		assertEquals(3, p.line);
		assertEquals(7, p.column);
		assertEquals(6, p.length);
	}

}
