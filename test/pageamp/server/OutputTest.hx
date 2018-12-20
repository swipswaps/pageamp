package pageamp.server;

import haxe.unit.TestCase;
import htmlparser.HtmlDocument;
import pageamp.server.Loader;
import pageamp.server.Output;

using pageamp.web.DomTools;

class OutputTest extends TestCase {

	function testLogicIds() {
		var src = new HtmlDocument('<html lang="$'+'{\'es\'}">'
		+ '<head></head><body></body></html>');
		var dst = TestAll.getDoc();
		var pag = Loader.loadPage(src, dst, '/', 'test.local', '/');
		Output.addIds(pag);
		assertEquals('<html lang="es"><head data-pa="3"></head>'
		+ '<body data-pa="4"></body></html>', dst.domToString());
	}

}
