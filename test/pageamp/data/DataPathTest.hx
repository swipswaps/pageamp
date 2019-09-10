/*
 * Copyright (c) 2018-2019 Ubimate Technologies Ltd and PageAmp contributors.
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

package pageamp.data;

import pageamp.web.URL;
import pageamp.data.DataProvider;
import pageamp.data.DataPath;
import haxe.unit.TestCase;

//TODO: add test for '..' (parent operator)
class DataPathTest extends TestCase {
	var doc = Xml.parse('<root id="main">
		<item id="1">text 1</item>
		<item id="2">text 2</item>
		<item id="3">text 3</item>
		<list>
			<item id="1">list text 1</item>
			<item id="2">list text 2</item>
			<item id="3">list text 3</item>
		</list>
	</root>');

	public function testCountLocalItems() {
		var str = '<root><item id="1"/><item id="2"/><item id="3"/></root>';
		var xml : Xml = Xml.parse(str).firstElement();
		var xpath = new DataPath('/root/item');
		var res = xpath.selectNodes(xml);
		var count = 0;
		for (r in res) {
			count++;
		}
		assertEquals(3, count);
	}

	public function testCountAllItems() {
		var str = '<root><item id="1"/><item id="2"/><item id="3"/></root>';
		var xml : Xml = Xml.parse(str).firstElement();
		var xpath = new DataPath('//item');
		var res = xpath.selectNodes(xml);
		var count = 0;
		for (r in res) {
			count++;
		}
		assertEquals(3, count);
	}

	public function testAttributeCompare() {
		var str = '<root><item id="1"/><item id="2"/><item id="21"/><item id="3"/></root>';
		var xml = Xml.parse(str).firstElement();
		var xpath = new DataPath("/root/item[@id<3]");
		var res = xpath.selectNodes(xml);
		var count = 0;
		for (r in res) {
			count++;
		}
		assertEquals(2, count);
	}

	public function testAttributeNotEqualString() {
		var xpath = new DataPath("root/item[@id!='2']");
		var nodes = xpath.selectNodes(doc);
		assertEquals(2, nodes.length);
		assertEquals('1', nodes[0].get('id'));
		assertEquals('3', nodes[1].get('id'));
	}

	public function testAttributeNotEqualNumber() {
		var xpath = new DataPath("root/item[@id!=2]");
		var nodes = xpath.selectNodes(doc);
		assertEquals(2, nodes.length);
		assertEquals('1', nodes[0].get('id'));
		assertEquals('3', nodes[1].get('id'));
	}

	public function testAttributeEqualString() {
		var xpath = new DataPath("root/item[@id='2']");
		var nodes = xpath.selectNodes(doc);
		assertEquals(1, nodes.length);
		assertEquals('2', nodes[0].get('id'));
	}

	public function testAttributeEqualNumber() {
		var xpath = new DataPath("root/item[@id=2]");
		var nodes = xpath.selectNodes(doc);
		assertEquals(1, nodes.length);
		assertEquals('2', nodes[0].get('id'));
	}

	public function testAttributeValues() {
		var xpath = new DataPath('root/item/@id');
		var values = xpath.selectValues(doc);
		assertEquals(3, values.length);
		assertEquals('1', values[0]);
		assertEquals('2', values[1]);
		assertEquals('3', values[2]);
	}

	public function testTextValues() {
		var xpath = new DataPath('root/item/text()');
		var values = xpath.selectValues(doc);
		assertEquals(3, values.length);
		assertEquals('text 1', values[0]);
		assertEquals('text 2', values[1]);
		assertEquals('text 3', values[2]);
	}

	public function testTrailingSlash() {
		var node = doc.firstElement();
		var values = new DataPath('root/item/@id').selectValues(node);
		assertEquals(0, values.length);
		var values = new DataPath('/root/item/@id').selectValues(node);
		assertEquals(3, values.length);
	}

	public function testWildcard() {
		var xpath = new DataPath("root/*[@id!='2']");
		var nodes = xpath.selectNodes(doc);
		assertEquals(3, nodes.length);
	}

	public function testDoubleSlash1() {
		var nodes = new DataPath("//item[@id!='2']").selectNodes(doc);
		assertEquals(4, nodes.length);
	}

	public function testDoubleSlash2() {
		var nodes = new DataPath("/root//item[@id!='2']").selectNodes(doc);
		assertEquals(4, nodes.length);
	}

	public function testDoubleSlash3() {
		var xpath = new DataPath("/root");
		var node = xpath.selectNode(doc);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assertEquals(4, nodes.length);
	}

	public function testDoubleSlash4() {
		var node = new DataPath("//list").selectNode(doc);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assertEquals(2, nodes.length);
	}

	public function testDatasource1() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new TestDataProvider());
		var nodes = new DataPath("source1:/dummy/item", function(id:String) {
			return sources.get(id);
		}).selectNodes(null);
		assertEquals(3, nodes.length);
	}

	public function testDatasource2() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new TestDataProvider());
		var nodes = new DataPath("source1://item", function(id:String) {
			return sources.get(id);
		}).selectNodes(null);
		assertEquals(6, nodes.length);
	}

	public function testDatasource3() {
		var sources = new Map<String,DataProvider>();
		sources.set('source1', new TestDataProvider());
		var node = new DataPath("source1://list", function(id:String) {
			return sources.get(id);
		}).selectNode(null);
		var nodes = new DataPath("//item[@id!='2']").selectNodes(node);
		assertEquals(2, nodes.length);
	}

	public function testNullXpathNullNode() {
		var node = new DataPath(null).selectNode(null);
		assertTrue(node == null);
	}

	public function testNullXpathNonNullNode() {
		var node = new DataPath(null).selectNode(doc);
		assertTrue(node == null);
	}

	public function testEmptyXpathNullNode() {
		var node = new DataPath('').selectNode(null);
		assertTrue(node == null);
	}

	public function testEmptyXpathNonNullNode() {
		var node = new DataPath('').selectNode(doc);
		assertTrue(node == doc);
	}

	public function testNonEmptyXpathNullNode1() {
		var node = new DataPath('*').selectNode(null);
		assertTrue(node == null);
	}

	public function testNonEmptyXpathNullNode2() {
		var node = new DataPath('text()').selectValue(null);
		assertTrue(node == null);
	}

}

class TestDataProvider implements DataProvider {
	public var doc: Xml;

	public function new() {
		doc = Xml.parse('<dummy>
			<item id="1">text 1</item>
			<item id="2">text 2</item>
			<item id="3">text 3</item>
			<list>
				<item id="1">list text 1</item>
				<item id="2">list text 2</item>
				<item id="3">list text 3</item>
			</list>
		</dummy>');
	}

	public function getData(?url:URL): Xml {
		return doc;
	}

	public function isRequesting(): Bool {
		return false;
	}

	public function abortRequest(): Void {
		// nop
	}

}