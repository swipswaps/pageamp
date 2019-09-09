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

package pageamp.core;

import pageamp.react.Value;
import pageamp.util.PropertyTool;
import pageamp.web.DomTools;
import pageamp.react.ValueContext;
import pageamp.util.Set;
#if client
	import js.html.Window;
#end

using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

class Page extends Element implements Root {
	public static inline var WINDOW_ATTR = 'window';
//	public static inline var REDIRECT_ATTR = 'pageRedirect';
	public static inline var FSPATH_PROP = 'pageFSPath';
	public static inline var URI_PROP = 'pageURI';
	public static inline var PAGE_LANG = Element.ATTRIBUTE_PFX + 'lang';
	// isomorphism
	public static inline var ISOPROPS_ID = 'pageamp_descr';
	public static inline var ISOCHILDREN_PROP = Node.NODE_PFX + 'c';

	public var doc: DomDocument;
	public var head: Head;
	public var body: Body;

	public function new(doc:DomDocument, ?props:Props, ?cb:Dynamic->Void) {
		this.doc = doc;
		props = props.set(Element.ELEMENT_DOM, doc.domGetBody());
		super(null, props, cb);
		head == null ? head = new Head(this) : null;
		body == null ? body = new Body(this) : null;
		set('pageInit', true);
		scope.context.refresh();
	}

	// =========================================================================
	// as Root
	// =========================================================================

	public function typeInit(node:Node, cb:Void->Void): Void {
		var key = Type.getClassName(Type.getClass(node));
		if (!initializations.exists(key)) {
			initializations.add(key);
			cb();
		}
	}

	public function nextId(): Int {
		return currId++;
	}

	public function getDocument(): DomDocument {
		return doc;
	}

	public function createDomElement(name:String,
	                                 ?props:Props,
	                                 ?parent:DomElement,
	                                 ?before:DomNode): DomElement {
		var ret = doc.domCreateElement(name);
		for (k in props.keys()) {
			var v = props.get(k);
			v != null ? ret.domSet(k, Std.string(v)) : null;
		}
		parent != null ? parent.domAddChild(ret, before) : null;
		return ret;
	}

//	public function createDomTextNode(text:String): DomTextNode {
//		return doc.domCreateTextNode(text);
//	}

	public function createDomTextNode(text:String,
	                                  ?parent:DomElement,
	                                  ?before:DomNode): DomTextNode {
		var ret = doc.domCreateTextNode(text);
		parent != null ? parent.domAddChild(ret, before) : null;
		return ret;
	}

	public function createDomComment(text:String,
	                                 ?parent:DomElement,
	                                 ?before:DomNode): DomTextNode {
		var ret = doc.domCreateComment(text);
		parent != null ? parent.domAddChild(ret, before) : null;
		return ret;
	}

	public function getDefine(name:String): Define {
		return defines.get(name);
	}

	public function setDefine(name:String, def:Define): Void {
		defines.set(name, def);
	}

	public function getComputedStyle(e:DomElement,
	                                 name:String,
	                                 ?pseudoElt:String): String {
#if client
		var w:Window = props.get(WINDOW_ATTR);
		var s:Props = (w != null ? w.getComputedStyle(e, pseudoElt) : null);
		return s.get(name, '');
#else
		return '';
#end
	}

	public function getContext(): ValueContext {
		return scope.context;
	}

	// =========================================================================
	// private
	// =========================================================================
	var currId = 1;
	var initializations(default,null) = new Set<String>();
	var defines = new Map<String, Define>();

	override function isDynamicValue(k:String, v:Dynamic): Bool {
		return k == PAGE_LANG ? true : super.isDynamicValue(k, v);
	}

	override function newValueDelegate(v:Value) {
		if (v.name == PAGE_LANG) {
			v.nativeName = v.name.substr(Element.ATTRIBUTE_PFX.length);
			v.userdata = doc.domRootElement();
			v.cb = attributeValueCB;
			v.cb(v.userdata, v.nativeName, v.value);
		} else {
			super.newValueDelegate(v);
		}
	}

}
