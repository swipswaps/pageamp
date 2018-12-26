package pageamp.core;

import pageamp.core.Body;
import pageamp.core.Head;
import pageamp.core.Define;
import pageamp.util.PropertyTool;
import pageamp.core.Element;
import pageamp.core.Page;
import haxe.unit.TestCase;

using pageamp.web.DomTools;
using pageamp.util.PropertyTool;

@:access(pageamp.core.Element)
class PageTest extends TestCase {

	function testPage1() {
		var page = new Page(TestAll.getDoc());
		assertEquals('<html><head></head>'
		+ '<body></body></html>', page.doc.domToString());
	}

	function testPage2() {
		var props = PropertyTool.set(null, Page.PAGE_LANG, 'en');
		props.set(Element.ATTRIBUTE_PFX + 'class', 'app');
		var p = new Page(TestAll.getDoc(), props);
		assertEquals('<html lang="en"><head></head>'
		+ '<body class="app"></body></html>', p.doc.domToString());
		p.set(Page.PAGE_LANG, 'es');
		assertEquals('<html lang="es"><head></head>'
		+ '<body class="app"></body></html>', p.doc.domToString());
		p.set(Element.ATTRIBUTE_PFX + 'class', 'demo');
		assertEquals('<html lang="es"><head></head>'
		+ '<body class="demo"></body></html>', p.doc.domToString());
		p.set(Page.PAGE_LANG, null);
		assertEquals('<html><head></head>'
		+ '<body class="demo"></body></html>', p.doc.domToString());
	}

	function testPage3() {
		var p = new Page(TestAll.getDoc());
		assertEquals('<html><head></head>'
		+ '<body></body></html>', p.doc.domToString());
		p.set(Page.PAGE_LANG, 'es');
		assertEquals('<html lang="es"><head></head>'
		+ '<body></body></html>', p.doc.domToString());
		p.set(Element.ATTRIBUTE_PFX + 'class', 'demo');
		assertEquals('<html lang="es"><head></head>'
		+ '<body class="demo"></body></html>', p.doc.domToString());
	}

	function testPage4() {
		var p = new Page(TestAll.getDoc(), null, function(p:Page) {
			new Element(p, {innerText:'foo'});
		});
		assertEquals('<html><head></head>'
		+ '<body><div>foo</div></body></html>', p.doc.domToString());
	}

	function testPage5() {
		var p = new Page(TestAll.getDoc(), {v:'bar'}, function(p:Page) {
			new Element(p, {innerText:"v: ${v}"});
		});
		assertEquals('<html><head></head>'
		+ '<body><div>v: bar</div></body></html>', p.doc.domToString());
	}

	function testPageHead() {
		var p = new Page(TestAll.getDoc());
		assertTrue(p.head != null);
		assertEquals(p.head.dom, p.getDocument().domGetHead());
		assertEquals(p.get('head'), p.head.scope);
	}

	function testPageDefine() {
		var e;
		var p = new Page(TestAll.getDoc(), null, function(p:Page) {
			new Head(p, null, function(h:Head) {
				new Define(h, {n_def:'foo', n_ext:'span'}, function(d:Define) {
					new Element(d, {n_tag:'b', innerText:"title: ${title}"});
					new Element(d, {n_tag:'i', innerText:"text: ${text}"});
				});
			});
			new Body(p, null, function(b:Body) {
				e = new Element(b, {n_tag:':foo', title:'X', text:'Y'});
			});
		});
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: X</b><i>text: Y</i></span>'
		+ '</body></html>', p.doc.domToString());
	}

}
