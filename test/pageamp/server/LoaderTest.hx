/*
 * Copyright (c) 2018 Ubimate Technologies Ltd and PageAmp contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package pageamp.server;

import haxe.unit.TestCase;
import htmlparser.HtmlDocument;
import pageamp.server.Loader;

using pageamp.web.DomTools;

class LoaderTest extends TestCase {

	function testLoader1() {
		var src = new HtmlDocument('<html><head></head><body></body></html>');
		var dst = TestAll.getDoc();
		var pag = Loader.loadPage(src, dst, '/', 'test.local', '/');
		var out = dst.domToString();
		assertEquals('<html><head></head><body></body></html>', out);
	}

	function testLoader2() {
		var src = new HtmlDocument('<html lang="en">'
		+ '<head></head><body></body></html>');
		var dst = TestAll.getDoc();
		var pag = Loader.loadPage(src, dst, '/', 'test.local', '/');
		var out = dst.domToString();
		assertEquals('<html lang="en"><head></head><body></body></html>', out);
	}

	function testLoader3() {
		var src = new HtmlDocument('<html lang="$'+'{\'es\'}">'
		+ '<head></head><body id="1"></body></html>');
		var dst = TestAll.getDoc();
		var pag = Loader.loadPage(src, dst, '/', 'test.local', '/');
		var out = dst.domToString();
		assertEquals('<html lang="es"><head></head>'
		+ '<body id="1"></body></html>', out);
	}

	function testDefine1() {
		var src = new HtmlDocument('<html><head>'
		+ '<:define :tag="test:div" :text="">$'+'{text}</:define>'
		+ '</head><body id="1"><:test :text="Foo"/></body></html>');
		var s = src.toString();
		var dst = TestAll.getDoc();
		var pag = Loader.loadPage(src, dst, '/', 'test.local', '/');
		var out = dst.domToString();
		assertEquals('<html><head></head>'
		+ '<body id="1"><div>Foo</div></body></html>', out);
	}

}
