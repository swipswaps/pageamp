package pageamp.server;

import pageamp.server.PreprocessorParser;
import haxe.unit.TestCase;

class PreprocessorParserTest extends TestCase {

	function testColumnTag() {
		var doc = PreprocessorParser.parseDoc('<:tag></:tag>');
		assertEquals('<:tag />', doc.toString());
	}

}
