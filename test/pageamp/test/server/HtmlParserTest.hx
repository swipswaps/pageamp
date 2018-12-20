package pageamp.test.server;

import pageamp.server.PreprocessorParser;
import haxe.unit.TestCase;

class HtmlParserTest extends TestCase {

	function testColumnTag() {
		var doc = PreprocessorParser.parseDoc('<:tag></:tag>');
		assertEquals('<:tag />', doc.toString());
	}

}
