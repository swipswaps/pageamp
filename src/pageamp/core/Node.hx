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

package pageamp.core;

import pageamp.react.ValueContext;
import pageamp.react.ValueScope;
import pageamp.web.DomTools.DomNode;
import pageamp.react.Value;
import pageamp.util.BaseNode;
import pageamp.util.PropertyTool;

using pageamp.web.DomTools;
using pageamp.util.PropertyTool;

/**
* Common abstract superclass for ubimate.core package.
**/
class Node extends BaseNode {
	public static inline var NODE_PREFIX = 'n_';
	public static inline var NODE_PLUG = NODE_PREFIX + 'plug';
	public static inline var NODE_INDEX = NODE_PREFIX + 'index';
	public var id: Int;
	public var props: Props;
	public var root(get,null): Root;
	public inline function get_root(): Root return untyped baseRoot;
	public var parent(get,null): Node;
	public inline function get_parent(): Node return untyped baseParent;
	public var children(get,null): Array<Node>;
	public inline function get_children(): Array<Node> return cast baseChildren;

	public function new(parent:Node, ?props:Props, ?cb:Dynamic->Void) {
		this.props = props;
		super(parent, props.get(NODE_PLUG), props.get(NODE_INDEX), cb);
	}

	#if !debug inline #end
	public function getProp(key:String, ?defval:Dynamic) {
		return props.get(key, defval);
	}

	public function set(key:String, val:Dynamic, push=true): Value {
		scope == null ? makeScope() : null;
		return scope.set(key, val, push);
	}

//	// this forces an update push to dependent values even if val is the same
//	public function force(key:String, val:Dynamic) {
//		//TODO
//	}

	public function get(key:String, pull=true): Dynamic {
		return (scope != null ? scope.get(key, pull) : null);
	}

	#if (!test) inline #end
	public function refresh() {
		scope != null ? scope.refresh() : null;
	}

//#if test
//	public function toString() {
//		var name = Type.getClassName(Type.getClass(this)).split('.').pop();
//		var content = '';
//		var plug = 'default';
//		var scope = 'n';
//		var domNode = getDomNode();
//		if (domNode.domIsElement()) {
//			content = DomTools.domTagName(untyped domNode);
//			plug = cast(this, Element).getProp(Element.PLUG_PROP, 'default');
//			this.scope != null ? scope = 'y' : null;
//		} else if (domNode.domIsTextNode()) {
//			content = cast(domNode, DomTextNode).domGetText();
//		}
//		return '$name:${id}:$plug:$scope:$content';
//	}
//
//	public function dump() {
//		var sb = new StringBuf();
//		var f = null;
//		f = function(n:Node, level:Int) {
//			for (i in 0...level) sb.add('\t');
//			sb.add(n.toString() + '\n');
//			for (c in n.children) {
//				f(untyped c, level + 1);
//			}
//		}
//		f(this, 0);
//		return sb.toString();
//	}
//#end

	// =========================================================================
	// abstract methods
	// =========================================================================

	public function staticInit() {}
	public function getDomNode(): DomNode return null;
	public function cloneTo(parent:Node, ?index:Int): Node return null;

	// =========================================================================
	// util
	// =========================================================================

	public static function makeCamelName(n:String): String {
		return ~/(\-\w)/g.map(n, function(re:EReg): String {
			return n.substr(re.matchedPos().pos + 1, 1).toUpperCase();
		});
	}

	public static function makeHyphenName(n:String): String {
		return ~/([0-9a-z][A-Z])/g.map(n, function(re:EReg): String {
			var p = re.matchedPos().pos;
			return n.substr(p, 1).toLowerCase()
			+ '-'
			+ n.substr(p + 1, 1).toLowerCase();
		});
	}

	// =========================================================================
	// private
	// =========================================================================

	override function init() {
		root.typeInit(this, staticInit);
		id = root.nextId();
		parent == null ? makeScope() : null;
	}

	function isDynamicValue(k:String, v:Dynamic) {
		return v != null
			&& Std.is(v, String)
			&& !Value.isConstantExpression(untyped v);
	}

	function parentWithNonNullProp(key:String): Node {
		var ret = null;
		var p = parent;
		while (p != null) {
			if (p.props.get(key) != null) {
				ret = p;
				break;
			}
			p = p.parent;
		}
		return ret;
	}

	// =========================================================================
	// react
	// =========================================================================
	var scope: ValueScope;

	public function getScope(ascend=true): ValueScope {
		var ret:ValueScope = scope;
		if (ret == null && ascend && parent != null) {
			ret = parent.getScope();
		}
		return ret;
	}

	function makeScope(?name:String) {
		var pn = parent;
		var ps:ValueScope = null;
		while (pn != null) {
			if (pn.scope != null) {
				ps = pn.scope;
				break;
			}
			pn = pn.parent;
		}
		if (ps == null) {
			scope = new ValueContext(this).main;
		} else {
			var ctx = ps.context;
			scope = new ValueScope(ctx, ps, ctx.newScopeUid(), name);
			scope.set('parent', ps).unlink();
			scope.set('getNodeIndex', getIndex).unlink();
		}
		name != null ? scope.set('name', name).unlink() : null;
		scope.newValueDelegate = newValueDelegate;
		scope.owner = this;
	}

	function newValueDelegate(v:Value) {}

}
