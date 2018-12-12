package pageamp.test;

import pageamp.test.core.*;
import pageamp.test.web.*;
import pageamp.test.react.*;
import pageamp.util.Test;

class PageAmpTests extends TestRoot {

	static public function main() {
		new PageAmpTests(function(p:Test) {
			new React(p, function(p:Test) {
				new ScopeTest(p);
				new ValueTest(p);
			});
			new Web(p, function(p:Test) {
				new DomToolsTest(p);
			});
			new Core(p, function(p:Test) {
				new NodeTest(p);
				new ElementTest(p);
				new TextTest(p);
				new PageTest(p);
				new HeadTest(p);
				new DataTest(p);
				new DefineTest(p);
			});
		}, null, 'http://localhost/.pageamptest/php/index.php?rpc=');
	}
}

class React extends Test {}
class Web extends Test {}
class Core extends Test {}
