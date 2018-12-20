package pageamp.core;

import pageamp.util.PropertyTool;
import pageamp.core.ElementTest.TestRootElement;
import haxe.unit.TestCase;
import pageamp.core.*;
import pageamp.web.DomTools;

using pageamp.web.DomTools;
using pageamp.util.PropertyTool;

class DefineTest extends TestCase {

	function testDefine1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var e:Element = null;
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		var p = new Element(root, props);
		new Define(p, {n_def:'foo', n_ext:'span'}, function(p:Define) {
			new Element(p, {n_tag:'b', innerText:"title: ${title}"});
			new Element(p, {n_tag:'i', innerText:"text: ${text}"});
		});
		e = new Element(p, {n_tag:':foo'});
		root.refresh();
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: </b><i>text: </i></span>'
		+ '</body></html>', doc.domToString());
		e.set('title', 'Z');
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: </b><i>text: </i></span>'
		+ '</body></html>', doc.domToString());
	}

	function testDefine2() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var e:Element = null;
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		var p = new Element(root, props);
		new Define(p, {n_def:'foo', n_ext:'span'}, function(p:Define) {
			new Element(p, {n_tag:'b', innerText:"title: ${title}"});
			new Element(p, {n_tag:'i', innerText:"text: ${text}"});
		});
		e = new Element(p, {n_tag:':foo', title:'X', text:'Y'});
		root.refresh();
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: X</b><i>text: Y</i></span>'
		+ '</body></html>', doc.domToString());
		e.set('title', 'Z');
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: Z</b><i>text: Y</i></span>'
		+ '</body></html>', doc.domToString());
	}

	function testDefine3() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var e:Element = null;
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		var p = new Element(root, props);
		new Define(p, {
			n_def: 'foo',
			n_ext: 'span',
			title: 'A',
			text: 'B',
		}, function(p:Define) {
			new Element(p, {n_tag:'b', innerText:"title: ${title}"});
			new Element(p, {n_tag:'i', innerText:"text: ${text}"});
		});
		e = new Element(p, {n_tag:':foo'});
		root.refresh();
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: A</b><i>text: B</i></span>'
		+ '</body></html>', doc.domToString());
		e.set('title', 'Z');
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: Z</b><i>text: B</i></span>'
		+ '</body></html>', doc.domToString());
	}

	function testDefine4() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var e:Element = null;
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		var p = new Element(root, props);
		new Define(p, {
			n_def: 'foo',
			n_ext: 'span',
			title: 'A',
			text: 'B',
		}, function(p:Define) {
			new Element(p, {n_tag:'b', innerText:"title: ${title}"});
			new Element(p, {n_tag:'i', innerText:"text: ${text}"});
		});
		e = new Element(p, {n_tag:':foo', title:'X', text:'Y'});
		root.refresh();
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: X</b><i>text: Y</i></span>'
		+ '</body></html>', doc.domToString());
		e.set('title', 'Z');
		assertEquals('<html>'
		+ '<head></head><body>'
		+ '<span><b>title: Z</b><i>text: Y</i></span>'
		+ '</body></html>', doc.domToString());
	}

	function testSlot1() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var e:Element = null;
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		var p = new Element(root, props);
		new Define(p, {n_def:'item', n_ext:'li'}, function(p:Define) {
			new Element(p, {n_tag:'span', n_slot:'title'});
		});
		e = new Element(p, {n_tag:':item'}, function(p:Element) {
			new Element(p, {n_tag:'i', n_plug:'title', innerText:'x'});
		});
		root.refresh();
		assertEquals('<html><head></head><body>'
		+ '<li><span><i>x</i></span></li>'
		+ '</body></html>', doc.domToString());
	}

	function testSlot2() {
		var doc = TestAll.getDoc();
		var root = new TestRootElement(doc);
		var e:Element = null;
		var props = PropertyTool.set(null, Element.ELEMENT_DOM, root.body);
		var p = new Element(root, props);
		new Define(p, {n_def:'item', n_ext:'li'}, function(p:Define) {
			new Element(p, {n_tag:'span', n_slot:'title'});
		});
		new Define(p, {n_def:'bold', n_ext:'item'}, function(p:Define) {
			new Element(p, {n_tag:'b', n_plug:'title', n_slot:'title'});
		});
		e = new Element(p, {n_tag:':bold'}, function(p:Element) {
			new Element(p, {n_tag:'i', n_plug:'title', innerText:'x'});
		});
		root.refresh();
		assertEquals('<html><head></head><body>'
		+ '<li><span><b><i>x</i></b></span></li>'
		+ '</body></html>', doc.domToString());
	}

}
