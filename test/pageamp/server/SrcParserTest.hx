package pageamp.server;

import pageamp.server.SrcParser;
import haxe.unit.TestCase;

class SrcParserTest extends TestCase {

	function testColumnTag() {
		var doc = SrcParser.parseDoc('<:tag></:tag>');
		assertEquals('<:tag />', doc.toString());
	}

}
