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
	public static inline var PAGE_LANG = Element.ATTRIBUTE_PREFIX + 'lang';
	public var doc: DomDocument;
	public var head: Head;

	public function new(doc:DomDocument, ?props:Props, ?cb:Dynamic->Void) {
		this.doc = doc;
		props = props.set(Element.ELEMENT_DOM, doc.domGetBody());
		super(null, props, cb);
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

	public function createDomTextNode(text:String): DomTextNode {
		return doc.domCreateTextNode(text);
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
		var w:Window = props.get('window');
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

	override function init() {
		super.init();
		head = new Head(this);
	}

	override function isDynamicValue(k:String, v:Dynamic): Bool {
		return k == PAGE_LANG ? true : super.isDynamicValue(k, v);
	}

	override function newValueDelegate(v:Value) {
		if (v.name == PAGE_LANG) {
			v.nativeName = v.name.substr(Element.ATTRIBUTE_PREFIX.length);
			v.userdata = doc.domRootElement();
			v.cb = attributeValueCB;
			v.cb(v.userdata, v.nativeName, v.value);
		} else {
			super.newValueDelegate(v);
		}
	}

}
