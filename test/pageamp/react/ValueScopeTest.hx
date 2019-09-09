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

package pageamp.react;

import haxe.unit.TestCase;
import pageamp.react.ValueContext;

using pageamp.web.DomTools;

class ValueScopeTest extends TestCase {

	public function testScope1() {
		var context = new ValueContext();
		var scope = context.main;
		scope.set('v', 3);
		assertEquals(3, scope.get('v'));
		context.refresh();
		assertEquals(3, scope.get('v'));
		scope.set('v', 'foo');
		assertEquals('foo', scope.get('v'));
		context.refresh();
		assertEquals('foo', scope.get('v'));
	}

	public function testScope2() {
		var context = new ValueContext();
		var scope = context.main;
		scope.set('v', "${3}");
		assertTrue(scope.get('v') == null);
		context.refresh();
		assertEquals(3, scope.get('v'));
		scope.set('v', 'foo');
		assertEquals('foo', scope.get('v'));
		context.refresh();
		assertEquals('foo', scope.get('v'));
	}

}
