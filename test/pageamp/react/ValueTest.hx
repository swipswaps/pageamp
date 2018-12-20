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

package pageamp.react;

import haxe.unit.TestCase;
import pageamp.react.Value;
import pageamp.react.ValueContext;
import pageamp.react.ValueScope;

using pageamp.util.MapTool;

class ValueTest extends TestCase {

	public function testValue1() {
        var context = new ValueContext();
        var scope = context.main;
        var count = 0;
        var v = new Value('foo', null, null, scope, null, function(u,k,v) {
            assertEquals('bar', v);
            count++;
        });
        assertEquals('foo', v.value);
        assertEquals('foo', v.get());
        v.set('bar');
        assertEquals(1, count);
	}

	public function testValue2() {
        var context = new ValueContext();
        var scope = context.main;
        var count = 0;
        var v = new Value('foo', null, null, scope, null, function(u,k,v) {
            assertEquals(count == 0 ? 'foo' : 'bar', v);
            count++;
        });
        assertEquals('foo', v.value);
        assertEquals('foo', v.get());
        context.refresh();
        assertEquals(1, count);
        v.set('bar');
        assertEquals(2, count);
	}

	public function testValue3() {
        var context = new ValueContext();
        var scope = context.main;
        var count = 0;
        var v = new Value(1, null, null, scope, null, function(u,k,v) {
            assertEquals(count == 0 ? 1 : 2, v);
            count++;
        });
        assertEquals(1, v.value);
        assertEquals(1, v.get());
        context.refresh();
        assertEquals(1, count);
        v.set(2);
        assertEquals(2, count);
	}

	public function testValue4() {
        var context = new ValueContext();
        var scope = context.main;
        var count = 0;
        var v = new Value("${'foo'}", null, null, scope, null, function(u,k,v) {
            count++;
        });
        assertEquals(0, count);
        assertTrue(v.value == null);
        assertTrue(v.get() == null);

        context.refresh();
        assertEquals(1, count);
        assertEquals('foo', v.value);
        assertEquals('foo', v.get());

        v.set('bar');
        assertEquals(2, count);
        assertEquals('bar', v.value);
        assertEquals('bar', v.get());

        context.refresh();
        assertEquals(3, count);
        assertEquals('foo', v.value);
        assertEquals('foo', v.get());
	}

	public function testDependency1() {
        var context = new ValueContext();
        var scope = context.main;

        var v1Count = 0;
        var v2Count = 0;
        var v1 = new Value(1, 'v1', null, scope, null, function(u,k,v) {
            v1Count++;
        });
        var v2 = new Value("${v1 + 1}", 'v2', null, scope, null, function(u,k,v) {
            v2Count++;
        });

//        assertEquals(2, context.valueInstances.mapSize());
//        assertEquals(v1, context.valueInstances.get(v1.uid));
//        assertEquals(v2, context.valueInstances.get(v2.uid));
        assertFalse(context.isRefreshing);
        assertEquals(0, context.cycle);
        assertEquals(0, v1.cycle);
        assertEquals(0, v2.cycle);
        assertEquals(0, v1Count);
        assertEquals(0, v2Count);
        assertEquals(1, v1.value);
        assertTrue(v2.value == null);

        context.refresh();

        assertFalse(context.isRefreshing);
        assertEquals(1, context.cycle);
        assertEquals(1, v1.cycle);
        assertEquals(1, v2.cycle);
        assertEquals(1, v1Count);
        assertEquals(1, v2Count);
        assertEquals(1, v1.value);
        assertEquals(2, v2.value);
	}

	public function testDependency2() {
        var context = new ValueContext();
        var scope = context.main;

        var v1Count = 0;
        var v2Count = 0;
        var s1 = context.newScope();
        context.setGlobal('s1', s1);
        var v1 = new Value(1, 'v1', null, s1, null, function(u,k,v) {
            v1Count++;
        });
        var v2 = new Value("${s1.v1 + 1}", 'v2', null, scope, null, function(u,k,v) {
            v2Count++;
        });

//        assertEquals(2, context.valueInstances.mapSize());
//        assertEquals(v1, context.valueInstances.get(v1.uid));
//        assertEquals(v2, context.valueInstances.get(v2.uid));
        assertFalse(context.isRefreshing);
        assertEquals(0, context.cycle);
        assertEquals(0, v1.cycle);
        assertEquals(0, v2.cycle);
        assertEquals(0, v1Count);
        assertEquals(0, v2Count);
        assertEquals(1, v1.value);
        assertTrue(v2.value == null);

        context.refresh();

        assertFalse(context.isRefreshing);
        assertEquals(1, context.cycle);
        assertEquals(1, v1.cycle);
        assertEquals(1, v2.cycle);
        assertEquals(1, v1Count);
        assertEquals(1, v2Count);
        assertEquals(1, v1.value);
        assertEquals(2, v2.value);
	}

	function testMultiStatementExp1() {
		var context = new ValueContext();
		var scope = context.main;
		var b = new Value("$"+"{'val1'; 'val2'}", null, null, scope);
		assertTrue(b.value == null);
		context.refresh();
		assertEquals('val2', b.value);
	}

	function testMultiStatementExp2() {
		var context = new ValueContext();
		var scope = context.main;
		var a = new Value("ko", 'a', null, scope);
		var b = new Value("$"+"{a = 'ok'; 'done'}", null, null, scope);
		assertEquals('ko', a.value);
		assertTrue(b.value == null);
		context.refresh();
		assertEquals('ok', a.value);
		assertEquals('done', b.value);
	}

}
