package pageamp;

import pageamp.server.SrcParserTest;
import pageamp.server.OutputTest;
import pageamp.server.LoaderTest;
import haxe.unit.TestRunner;
import pageamp.core.DefineTest;
import pageamp.core.ElementTest;
import pageamp.core.HeadTest;
import pageamp.core.NodeTest;
import pageamp.core.PageTest;
import pageamp.core.TextTest;
import pageamp.data.DataPathTest;
import pageamp.react.ValueScopeTest;
import pageamp.react.ValueTest;
import pageamp.web.DomTools;
#if js
	import js.Browser;
#elseif php
	import php.Lib;
	import php.Web;
	import htmlparser.HtmlDocument;
#end

class TestAll {
	static var doc: DomDocument;

	public static function main() {
		new Runner(function(r:Runner) {
			doc = r.doc;
			// data
			r.add(new DataPathTest());
			// react
			r.add(new ValueScopeTest());
			r.add(new ValueTest());
			// core
			r.add(new NodeTest());
			r.add(new ElementTest());
			r.add(new TextTest());
			r.add(new DefineTest());
			r.add(new PageTest());
			r.add(new HeadTest());
			// server
			r.add(new SrcParserTest());
			r.add(new LoaderTest());
			r.add(new OutputTest());
			r.run();
		});
	}

	public static function getDoc(): DomDocument {
#if js
		doc.documentElement.innerHTML = '<head></head><body></body>';
		doc.documentElement.removeAttribute('lang');
		return doc;
#elseif php
		return new HtmlDocument('<html><head></head><body></body></html>');
#end
	}

}

class Runner extends TestRunner {
	public var doc: DomDocument;

	public function new(cb:Runner->Void) {
		super();
#if js
		// style
		var style = Browser.document.createStyleElement();
		style.innerHTML = 'body {color:#ccc;background:#222;}';
		Browser.document.head.appendChild(style);

		// create #haxe:trace div
		var iframe = Browser.document.createIFrameElement();
		iframe.style.position = 'absolute';
		iframe.style.opacity = '0';
		iframe.style.zIndex = '-1';
		iframe.onload = function(_) {
			doc = iframe.contentDocument;

			// customize TestRunner.print()
			var div = js.Browser.document.getElementById("haxe:trace");
			div.innerHTML = 'Client\n\n';
			TestRunner.print = function(v:Dynamic) {
				if (div != null) {
					var s = StringTools.htmlEscape(v+'');//.split("\n").join("<br/>");
					div.innerHTML += s;
				} else {
					untyped __js__("console").log(v+'');
				}
			}
			cb(this);
		}
		iframe.style.opacity = '0';
		Browser.document.body.appendChild(iframe);

#elseif php
		Lib.println('<html><head>'
		+ '<meta name="viewport" content="width=device-width, initial-scale=1">'
		+ '<style>body {color:#ccc;background:#222;}'
		+ '</style></head><body><pre>PHP\n');

		// customize TestRunner.print()
		TestRunner.print = function(v:Dynamic) {
			Lib.print(StringTools.htmlEscape(v+''));
		}

		cb(this);
#end
	}

	override public function run(): Bool {
		var ret = super.run();
#if php
		Lib.println('</pre></body></html>');
#end
		return ret;
	}

}