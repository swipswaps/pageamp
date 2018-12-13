package pageamp.core;

import pageamp.web.DomTools;
import pageamp.util.PropertyTool;
import pageamp.react.*;
import pageamp.util.BaseNode;
#if client
	import js.html.Window;
	import js.html.ResizeObserver;
#end

using StringTools;
using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

/**
* An Element represents a DOM Element.
**/
class Element extends Node {
	public static inline var ATTRIBUTE_PREFIX = 'a_';
	public static inline var CLASS_PREFIX = 'c_';
	public static inline var STYLE_PREFIX = 's_';
	public static inline var EVENT_PREFIX = 'ev_';
	public static inline var HANDLER_PREFIX = 'on_';
	// static attributes
	public static inline var ELEMENT_DOM = Node.NODE_PREFIX + 'dom';
	public static inline var ELEMENT_TAG = Node.NODE_PREFIX + 'tag';
	public static inline var ELEMENT_SLOT = Node.NODE_PREFIX + 'slot';
	public static inline var ELEMENT_ID = Node.NODE_PREFIX + 'id';
	// (replicated nodes)
	public static inline var SOURCE_PROP = Node.NODE_PREFIX + 'src';
	// predefined dynamic attributes
	public static inline var NAME_PROP = 'name';
	public static inline var INNERTEXT_PROP = 'innerText';
	public static inline var INNERHTML_PROP = 'innerHtml';
	// (databinding)
	public static inline var DATAPATH_PROP = 'datapath';
	// (replication)
	public static inline var FOREACH_PROP = 'foreach';
	public static inline var SORT_PROP = 'forsort';
	public static inline var TARGET_PROP = 'fortarget';
	public static inline var CLONE_INDEX = 'cloneIndex';
	// runtime object DOM property
	public static inline var PAGEAMP_OBJECT = 'pageamp';

	override public function set(key:String, val:Dynamic, push=true): Value {
		var ret = null;
		if (key.startsWith(ATTRIBUTE_PREFIX) && !isDynamicValue(key, val)) {
			key = Node.makeHyphenName(key.substr(ATTRIBUTE_PREFIX.length));
			attributeValueCB(dom, key, val);
		} else {
			scope == null ? makeScope() : null;
			ret = super.set(key, val, push);
		}
		return ret;
	}

	// =========================================================================
	// API
	// =========================================================================

	override public function makeScope(?name:String) {
		name == null ? name = props.get(NAME_PROP) : null;
		super.makeScope(name);
		set('this', scope);
		// node tree
		set('parentNode', scope.parent).unlink();
		set('siblingNodes', getSiblingScopes).unlink();
		set('childNodes', getChildScopes).unlink();
		set('childrenCount', "${dom.children.length}");
		set('removeSelf', removeSelf).unlink();
		// values
		set('animate', scope.animate).unlink();
		set('delayedSet', scope.delayedSet).unlink();
		set('sendTo', sendTo).unlink();
		// dom
		set('dom', dom);
		set('computedStyle', getComputedStyle).unlink();
		//initDatabinding();
		//initReplication();
	}

	// =========================================================================
	// define support
	// =========================================================================
	var def: Define;

	override function init() {
		init2();
	}

	// =========================================================================
	// private
	// =========================================================================
	var dom: DomElement;

	function init2() {
		super.init();
		makeDomElement();
		props.get(NAME_PROP) != null ? makeScope() : null;
		for (k in props.keys()) {
			if (!k.startsWith(Node.NODE_PREFIX)) {
				set(k, props.get(k));
			}
		}
		if (props.exists(FOREACH_PROP)) {
			//TODO: hiding mechanism dom.domSet('style', 'display:none');
		}
#if client
		PropertyTool.set(dom, PAGEAMP_OBJECT, this);
#end
	}

	function makeDomElement() {
		if ((dom = props.get(ELEMENT_DOM)) == null) {
			dom = root.createDomElement(props.get(ELEMENT_TAG, 'div'));
		}
	}

	function getSiblingScopes(?having:String,
	                          ?equal:Dynamic,
	                          ?nonEqual:Dynamic) {
		var ret = [];
		if (baseParent != null) {
			for (node in parent.children) {
				if (node != this && node.scope != null) {
					var v = (having != null
					? node.scope.values.get(having)
					: null);
					if (having != null && v == null) {
						continue;
					}
					if (equal != null && (v == null || v.value != equal)) {
						continue;
					}
					if (nonEqual != null && v != null && v.value == nonEqual) {
						continue;
					}
					ret.push(node.scope);
				}
			}
		}
		return ret;
	}

	function getChildScopes() {
		var ret = [];
		for (node in children) {
			node.scope == null ? node.makeScope() : null;
			ret.push(node.scope);
		}
		return ret;
	}

	function removeSelf() {
		baseParent != null ? baseParent.removeChild(this) : null;
	}

	function sendTo(target:Dynamic, key:String, val:Dynamic) {
		if (target != null) {
			if (Std.is(target, Array)) {
				var a:Array<ValueScope> = cast target;
				for (i in a) {
					sendTo(i, key, val);
				}
			} else if (Std.is(target, ValueScope)) {
				cast(target, ValueScope).delayedSet(key, val);
			}
		}
	}

	function getComputedStyle(name:String, pseudoElt=''): String {
		return root.getComputedStyle(name, pseudoElt);
	}

	#if !debug inline #end
	function makeNativeName(n:String, off=0) {
		return Node.makeHyphenName(n.substr(off));
	}

	// =========================================================================
	// react
	// =========================================================================

	override function newValueDelegate(v:Value) {
		var name = v.name;
		v.userdata = dom;
		if (name.startsWith(ATTRIBUTE_PREFIX)) {
			v.nativeName = makeNativeName(name, ATTRIBUTE_PREFIX.length);
			if (!props.exists(FOREACH_PROP) || v.nativeName != 'style') {
				v.cb = attributeValueCB;
			}
//		} else if (name.startsWith(CLASS_PREFIX)) {
//			v.nativeName = makeNativeName(name, CLASS_PREFIX.length);
//			v.cb = classValueCB;
//		} else if (name.startsWith(STYLE_PREFIX)) {
//			v.nativeName = makeNativeName(name, STYLE_PREFIX.length);
//			if (!props.exists(FOREACH_PROP)) {
//				v.cb = styleValueCB;
//			}
//		} else if (name.startsWith(EVENT_PREFIX)) {
//			v.unlink(); // non refreshed
//			if (v.isDynamic()) {
//				// contains script
//				var evname = name.substr(EVENT_PREFIX.length);
//				e.domAddEventHandler(evname, v.evGet);
//			}
//		} else if (name.startsWith(HANDLER_PREFIX)) {
//			v.unlink(); // non refreshed
//			if (v.isDynamic()) {
//				// contains script
//				//TODO: this only supports single expressions (no ';' separator)
//				var valname = name.substr(HANDLER_PREFIX.length);
//				var refname = NODE_PREFIX + page.nextId();
//				set(refname, "${" + valname + "}").cb = v.get3;
//			}
//		} else if (name == INNERTEXT_PROP) {
//			// INNERTEXT_PROP is a shortcut for having a Tag create a nested
//			// text node and keeping the latter's content updated with
//			// possible INNERTEXT_PROP changes.
//			// The normal way would be to explicitly create a Text inside
//			// the Tag, but Texts with dynamic content also create a nested
//			// marker element so the client code can look it up by ID and
//			// link it to the proper Text. This cannot be used in tags like
//			// <title>, hence this shortcut.
//			//
//			// NOTE: Preprocessor automatically uses this attribute when it
//			// finds elements with a single text node child containing
//			// dynamic expressions.
//			v.userdata = e;
//			v.cb = textValueCB;
//		} else if (name == INNERHTML_PROP) {
//			v.cb = htmlValueCB;
		}
		if (!v.isDynamic() && v.cb != null) {
			v.cb(v.userdata, v.nativeName, v.value);
		}
	}

	// =========================================================================
	// reflection
	// =========================================================================

	function attributeValueCB(e:DomElement, key:String, val:Dynamic) {
		e.domSet(key, (val != null ? Std.string(val) : null));
	}

}
