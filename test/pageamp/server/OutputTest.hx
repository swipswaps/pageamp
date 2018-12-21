package pageamp.server;

import haxe.unit.TestCase;
import htmlparser.HtmlDocument;
import pageamp.server.Loader;
import pageamp.server.Output;

using pageamp.web.DomTools;

class OutputTest extends TestCase {

	function testAddClient() {
		var src = new HtmlDocument('<html lang="$'+'{\'es\'}">'
		+ '<head></head><body></body></html>');
		var dst = TestAll.getDoc();
		var pag = Loader.loadPage(src, dst, '/', 'test.local', '/');
		Output.addClient(pag, null);
		var s = dst.domToString();
		assertEquals('<html lang="es">'
		+ '<head data-pa="2"></head>'
		+ '<body data-pa="1">'
		+ '<script>pageamp_descr = {"a_lang":"$'+'{\'es\'}","n_c":[{"n_id":2,"name":"head"}],"n_id":1,"pageFSPath":"/","pageURI":{"_query":null,"anchor":null,"authority":"","directory":"/","file":"","host":"test.local","params":null,"password":null,"path":"/","pathSlices":null,"port":null,"protocol":null,"query":null,"relative":"/","source":"/","user":null,"userInfo":null}};</script>\n'
		+ '<script src="/.pageamp/client/bin/pageamp.js"></script>\n'
		+ '</body></html>', s);
	}

}
