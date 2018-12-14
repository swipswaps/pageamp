package pageamp.test2;

import pageamp.test2.react.ValueTest;
import pageamp.test2.core.NodeTest;
import pageamp.test2.core.ElementTest;
import pageamp.test2.react.ScopeTest;
import pageamp.web.DomTools.DomDocument;
import haxe.unit.TestRunner;
#if js
	import js.Browser;
#elseif php
	import php.Web;
	import htmlparser.HtmlDocument;
#end

class TestAll {
#if js
	static var doc: DomDocument;
#end

	public static function main() {
#if js
		var iframe = Browser.document.createIFrameElement();
		iframe.onload = function(_) {
			doc = iframe.contentDocument;
			run();
		}
		iframe.style.opacity = '0';
		Browser.document.body.appendChild(iframe);
#elseif php
		Web.setHeader('Content-type', 'text/plain');
		run();
#end
	}

	public static function getDoc(): DomDocument {
#if js
		doc.documentElement.innerHTML = '<html><head></head><body></body></html>';
		return doc;
#elseif php
		return new HtmlDocument('<html><head></head><body></body></html>');
#end
	}

	public static function run() {
#if js
		var div = js.Browser.document.getElementById("haxe:trace");
		TestRunner.print = function(v:Dynamic) {
			if (div != null) {
				var s = StringTools.htmlEscape(v+'').split("\n").join("<br/>");
				div.innerHTML += s;
			} else {
				untyped __js__("console").log(v+'');
			}
		}
#end
		var r = new TestRunner();
		// react
		r.add(new ScopeTest());
		r.add(new ValueTest());
		// core
		r.add(new NodeTest());
		r.add(new ElementTest());
		r.run();
	}

}
