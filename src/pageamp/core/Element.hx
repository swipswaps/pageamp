package pageamp.core;

import pageamp.data.DataProvider;
import pageamp.data.DataPath;
import pageamp.util.Util;
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
	public static inline var ID_DOM_ATTRIBUTE = 'data-pa';
	public static inline var ATTRIBUTE_PFX = 'a_';
	public static inline var CLASS_PFX = 'c_';
	public static inline var CLASS_PFX2 = ':c-';
	public static inline var STYLE_PFX = 's_';
	public static inline var STYLE_PFX2 = ':s-';
	public static inline var EVENT_PFX = 'ev_';
	public static inline var EVENT_PFX2 = ':ev-';
	public static inline var HANDLER_PFX = 'on_';
	public static inline var HANDLER_PFX2 = ':on-';
	// static attributes
	public static inline var ELEMENT_DOM = Node.NODE_PFX + 'dom';
	public static inline var ELEMENT_TAG = Node.NODE_PFX + 'tag';
	public static inline var ELEMENT_SLOT = Node.NODE_PFX + 'slot';
	public static inline var ELEMENT_ID = Node.NODE_PFX + 'id';
	// (replicated nodes)
	public static inline var SOURCE_PROP = Node.NODE_PFX + 'src';
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

	public var dom: DomElement;

	override public function set(key:String, val:Dynamic, push=true): Value {
		var ret = null;
		if (key.startsWith(ATTRIBUTE_PFX) && !isDynamicValue(key, val)) {
			key = Node.makeHyphenName(key.substr(ATTRIBUTE_PFX.length));
			attributeValueCB(dom, key, val);
		} else {
			scope == null ? makeScope() : null;
			ret = super.set(key, val, push);
		}
		return ret;
	}

	// =========================================================================
	// abstract methods
	// =========================================================================

	override public function getDomNode(): DomNode {
		return dom;
	}

	override
	public function cloneTo(parent:Node, nesting:Int, ?index:Int): Node {
		var props = this.props.clone();
		props = props.set(Node.NODE_INDEX, index);
		props.remove(NAME_PROP);
		//props.remove(Node.NODE_INDEX);
		nesting < 1 ? props.remove(FOREACH_PROP) : null;
		// ensure clone's data system is initialized so it has its own data ctx
		if (!props.exists(DATAPATH_PROP) && !props.exists(FOREACH_PROP)) {
			props.set2(DATAPATH_PROP, null);
		}
		var clone = new Element(cast parent, props);
		// clones must have their own scope in order to have their own data ctx
		clone.scope == null ? clone.makeScope() : null;
		for (child in children) {
			child.cloneTo(clone, nesting + 1);
		}
		return clone;
	}

	// =========================================================================
	// define support
	// =========================================================================
	var def: Define;

	override function init() {
		var tagname = props.get(ELEMENT_TAG);
		if ((def = root.getDefine(tagname)) != null) {
			props.remove(ELEMENT_TAG);
			props = props.ensureWith(def.props);
		}
		init2();
		var f = null;
		f = function(p:Element, src:Element) {
			for (n in src.children) {
				if (Std.is(n, Element)) {
					var t = new Element(p, PropertyTool.clone(untyped n.props));
					collectSlot(t);
					f(t, untyped n);
				} if (Std.is(n, Text)) {
					new Text(p, untyped n.text);
				}
			}
		}
		var f2 = null;
		f2 = function(p:Element, def:Define) {
			def.ext != null ? f2(p, def.ext) : null;
			f(untyped p, def);
		}
		def != null ? f2(this, def) : null;
	}

	function collectSlot(n:Element) {
		var slot = n.props.get(ELEMENT_SLOT);
		if (slot != null) {
			slots == null ? slots = new Map<String, BaseNode>() : null;
			slots.set(slot, n);
		}
	}

	// =========================================================================
	// private
	// =========================================================================
	var hidden = false;

	function init2() {
		var v;
		super.init();
		makeDomElement();
		props.get(NAME_PROP) != null ? makeScope() : null;
		if ((v = props.get(FOREACH_PROP)) != null) {
			set(FOREACH_PROP, props.get(FOREACH_PROP));
			setHidden(true);
		} else if (parentWithNonNullProp(FOREACH_PROP) != null) {
			// nop
		} else {
			for (k in props.keys()) {
				if (!k.startsWith(Node.NODE_PFX)) {
					set(k, props.get(k));
				}
			}
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

	function setHidden(flag:Bool) {
		if ((hidden = flag)) {
#if !client
			dom.domSet('style', 'display: none;');
#else
			dom.style.setProperty('display', 'none');
#end
		} else {
#if !client
			dom.domSet('style', style);
#else
			if (display != null) {
				dom.style.setProperty('display', display);
			} else {
				dom.style.removeProperty('display');
			}
#end
		}
	}

	override function wasAdded(logicalParent:BaseNode,
	                           parent:BaseNode,
	                           ?i:Int) {
		if (props.get(ELEMENT_DOM) == null) {
			var p:DomElement = untyped parent.dom;
			var b:Node = (i != null ? untyped parent.baseChildren[i] : null);
			p.domAddChild(dom, b != null ? b.getDomNode() : null);
		}
	}

	override function wasRemoved(logicalParent:BaseNode, parent:BaseNode) {
		dom.domRemove();
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

	function computedStyle(name:String, pseudoElt=''): String {
		return root.getComputedStyle(dom, name, pseudoElt);
	}

	#if !debug inline #end
	function makeNativeName(n:String, off=0) {
		return Node.makeHyphenName(n.substr(off));
	}

	// =========================================================================
	// react
	// =========================================================================

	override public function makeScope(?name:String) {
		name == null ? name = props.get(NAME_PROP) : null;
		super.makeScope(name);
		//dom.domSet(ID_DOM_ATTRIBUTE, Std.string(id));
		set('this', scope).unlink();
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
		set('dom', dom).unlink();
		set('computedStyle', computedStyle).unlink();
		if (props.exists(FOREACH_PROP)) {
			initDatabinding();
			initReplication();
		} else if (props.exists(DATAPATH_PROP)) {
			initDatabinding();
		}
	}

	override function newValueDelegate(v:Value) {
		var name = v.name;
		v.userdata = dom;
		if (name.startsWith(ATTRIBUTE_PFX)) {
			v.nativeName = makeNativeName(name, ATTRIBUTE_PFX.length);
			if (!props.exists(FOREACH_PROP) || v.nativeName != 'style') {
				v.cb = attributeValueCB;
			}
		} else if (name.startsWith(CLASS_PFX)) {
			v.nativeName = makeNativeName(name, CLASS_PFX.length);
			v.cb = classValueCB;
		} else if (name.startsWith(STYLE_PFX)) {
			v.nativeName = makeNativeName(name, STYLE_PFX.length);
			if (!props.exists(FOREACH_PROP)) {
				v.cb = styleValueCB;
			}
		} else if (name.startsWith(EVENT_PFX)) {
			v.unlink(); // non refreshed
			if (v.isDynamic()) {
				// contains script
				var evname = name.substr(EVENT_PFX.length);
				dom.domAddEventHandler(evname, v.evGet);
			}
		} else if (name.startsWith(HANDLER_PFX)) {
			v.unlink(); // non refreshed
			if (v.isDynamic()) {
				// contains script
				//TODO: this only supports single expressions (no ';' separator)
				var valname = name.substr(HANDLER_PFX.length);
				var refname = Node.NODE_PFX + root.nextId();
				set(refname, "${" + valname + "}").cb = v.get3;
			}
		} else if (name == INNERTEXT_PROP) {
			// INNERTEXT_PROP is a shortcut for having a Tag create a nested
			// text node and keeping the latter's content updated with
			// possible INNERTEXT_PROP changes.
			// The normal way would be to explicitly create a Text inside
			// the Tag, but Texts with dynamic content also create a nested
			// marker element so the client code can look it up and
			// link it to the proper Text. This cannot be used in tags like
			// <title>, hence this shortcut.
			//
			// NOTE: Preprocessor automatically uses this attribute when it
			// finds elements with a single text node child containing
			// dynamic expressions.
			v.userdata = dom;
			v.cb = textValueCB;
		} else if (name == INNERHTML_PROP) {
			v.cb = htmlValueCB;
		}
		if (!v.isDynamic() && v.cb != null) {
			v.cb(v.userdata, v.nativeName, v.value);
		}
	}

	// -------------------------------------------------------------------------
	// INNERTEXT_PROP reflection
	// -------------------------------------------------------------------------

	function textValueCB(e:DomElement, _, val:Dynamic) {
		if (val != null) {
			dom.domSetInnerHTML(Std.string(val).split('<').join('&lt;'));
		}
	}

	// -------------------------------------------------------------------------
	// INNERHTML_PROP reflection
	// -------------------------------------------------------------------------

	function htmlValueCB(e:DomElement, _, val:Dynamic) {
		if (val != null) {
			dom.domSetInnerHTML(val != null ? Std.string(val) : '');
		}
	}

	// -------------------------------------------------------------------------
	// dom attribute reflection
	// -------------------------------------------------------------------------
	var style: String;

	function attributeValueCB(e:DomElement, key:String, val:Dynamic) {
		var s = (val != null ? Std.string(val) : null);
		if (key == 'style') {
			style = s;
			hidden ? null : e.domSet(key, s);
		} else {
			e.domSet(key, s);
		}
	}

	// -------------------------------------------------------------------------
	// class reflection
	// -------------------------------------------------------------------------
#if !client
	var classes: Map<String, Bool>;
	var willApplyClasses = false;
#else
	var resizeMonitor = false;
#end

	function classValueCB(e:DomElement, key:String, v:Dynamic) {
		var flag = Util.isTrue(v != null ? '$v' : '1');
#if !client
		classes == null ? classes = new Map<String, Bool>() : null;
		flag ? classes.set(key, true) : classes.remove(key);
		if (!willApplyClasses) {
			willApplyClasses = true;
			scope.context.addApply(applyClasses);
		}
#else
		if (flag) {
			dom.classList.add(key);
		} else {
			dom.classList.remove(key);
		}
	#if resizeMonitor
		if (key == Page.RESIZE_CLASS && flag && !resizeMonitor) {
			resizeMonitor = true;
			//TODO: these should be defined earlier in case ub1-resize class is
			//set, so other values can reliably depend on them; they should also
			//be reliably initializated with the actual clientWidth/Height after
			//the first refresh
			set('resizeWidth', -1).unlink();
			set('resizeHeight', -1).unlink();
			page.observeResize(e);
		}
	#end
#end
	}

#if !client
	function applyClasses() {
		willApplyClasses = false;
		var sb = new StringBuf();
		var sep = '';
		for (key in classes.keys()) {
			if (classes.get(key)) {
				sb.add(sep); sep = ' '; sb.add(key);
			}
		}
		var s = sb.toString();
		dom.domSet('class', s); //(s.length > 0 ? s : null));
	}
#end

	// -------------------------------------------------------------------------
	// style reflection
	// -------------------------------------------------------------------------
#if !client
	var styles: Map<String, String>;
	var willApplyStyles = false;
#else
	var display: String;
#end

	function styleValueCB(e:DomElement, key:String, val:Dynamic) {
		var s = (val != null ? Std.string(val) : null);
#if !client
		styles == null ? styles = new Map<String, String>() : null;
		val != null ? styles.set(key, s) : styles.remove(key);
		if (!willApplyStyles) {
			willApplyStyles = true;
			scope.context.addApply(applyStyles);
		}
#else
		if (key == 'display') {
			display = s;
			if (hidden) {
				return;
			}
		}
		if (val != null) {
			e.style.setProperty(key, s);
		} else {
			e.style.removeProperty(key);
		}
#end
	}

#if !client
	function applyStyles() {
		willApplyStyles = false;
		var sb = new StringBuf();
		var sep = '';
		for (key in styles.keys()) {
			//sb.add(sep); sep = ';';
			sb.add(key); sb.add(': '); sb.add(styles.get(key)); sb.add(';');
		}
		style = sb.toString();
		if (!hidden) {
			dom.domSet('style', style);
		}
	}
#end

	// =========================================================================
	// databinding
	// =========================================================================
	var currDatapathSrc: String;
	var currDatapathExp: DataPath;
	var dataQueries: Map<String,DataPath>;

	#if !debug inline #end
	function initDatabinding() {
		scope.set('__clone_dp', null);
		scope.setValueFn('__dp', dpFn);
		scope.set('dataGet', dataGet).unlink();
		scope.set('dataCheck', dataCheck).unlink();
	}

	function dpFn() {
		// dependencies
		var ret:Xml = get('__clone_dp');
		if (ret == null && parent != null) {
			ret = parent.get('__dp');
		}
		var src:String = get(DATAPATH_PROP);

		// evaluation
		if (src != null
			&& Std.is(src,String)
			&& (src = src.trim()).length > 0) {
			var exp = currDatapathExp;
			if (src != currDatapathSrc) {
				currDatapathSrc = src;
				exp = currDatapathExp = new DataPath(src, getDatasource);
			}
			ret = exp.selectNode(ret);
			if (hidden != (ret == null)) {
				setHidden(ret == null);
			}
		}

		return ret;
	}

	function dataGet(dpath:String): String {
		var ret = '';

		// dependencies
		var dp:Xml = getScope().get('__dp');

		if (dpath != null
			&& Std.is(dpath,String)
			&& (dpath = dpath.trim()).length > 0) {
			if (dataQueries == null) {
				dataQueries = new Map<String,DataPath>();
			}
			var query:DataPath = dataQueries.get(dpath);
			if (query == null) {
				query = new DataPath(dpath, getDatasource);
				dataQueries.set(dpath, query);
			}
			ret = query.selectValue(dp, '');
		} else {
			ret = (dp != null ? '1' : '');
		}

		return ret;
	}

	function dataCheck(?dpath:String): Bool {
		return (this.dataGet(dpath) != '');
	}

	function getDatasource(name:String): DataProvider {
		var ret:DataProvider = null;
		var scope = getScope();
		var v:Dynamic = scope.lookup(name);
		if (Std.is(v, DataProvider)) {
			ret = v;
		}
		return ret;
	}

	// =========================================================================
	// replication
	// =========================================================================
	//TODO: add support for cloneAddDelegate() and cloneRemoveDelegate()
	//in order to allow for add/remove animations
	public var clones: Array<Node>;
	#if test
		public var testCloneAdds = 0;
		public var testCloneRemoves = 0;
		public var testCloneRefreshes = 0;
		public var testCloneUpdates = 0;
	#end

	#if !debug inline #end
	function initReplication() {
		clones = [];
		scope.setValueFn('__dps', dpsFn);
	}

	function dpsFn() {
		var ret:Array<Xml> = null;
		// dependencies
		var dp = get('__dp');
		var src:String = get(FOREACH_PROP);

		// evaluation
		if (src != null
			&& Std.is(src,String)
			&& (src = src.trim()).length > 0) {
			var exp = currDatapathExp;
			if (src != currDatapathSrc) {
				currDatapathSrc = src;
				exp = currDatapathExp = new DataPath(src, getDatasource);
			}
			ret = exp.selectNodes(dp);
		}

		updateClones(ret);

		if (parent != null && parent.scope != null) {
			parent.scope.values.get('childrenCount').refresh(true);
		}

		return ret;
	}

	//TODO: sorting
	function updateClones(dnodes:Array<Xml>) {
		var p:Node = null;
		var before:Node = null;

		p = get(TARGET_PROP);

		if (p == null) {
			p = parent;
			//before = nextSibling();
			if (clones.length > 0) {
				before = cast clones[clones.length - 1].getNextSibling();
			} else {
				before = cast getNextSibling();
			}
		}

		var index = 0;
		if (dnodes != null) {
			for (dp in dnodes) {
				if (index < clones.length) {
					// reuse existing clone
					var clone = clones[index];
					refreshClone(clone, dp, index);
					#if test
						testCloneUpdates++;
					#end
				} else {
					// create new clone
					var clone = addClone(p, before, dp, index);
					if (clone != null) {
						clones.push(clone);
					}
				}
				index++;
			}
		}

		// remove unused clones
		while (index < clones.length) {
			removeClone(clones.pop());
		}
	}

	//TODO: use "index" instead of "before"
	function addClone(parent:Node, before:Node, dp:Xml, ci:Int): Node {
		var index = (before != null ? before.getIndex() : null);
		var ret = cloneTo(parent, 0, index);
		if (Std.is(ret, Element)) {
			var t:Element = untyped ret;
			t.props = t.props.set(SOURCE_PROP, id);
		}
		if (ret != null) {
			refreshClone(ret, dp, ci);
			#if test
				testCloneAdds++;
			#end
		}
		return ret;
	}

	function removeClone(clone:Node) {
		clone.parent.removeChild(clone);
		#if test
			testCloneRemoves++;
		#end
	}

	function refreshClone(clone:Node, dp:Xml, ci:Int) {
		clone.scope.clonedScope = true;
		clone.scope.set('__clone_dp', dp, false).unlink();
		clone.scope.set(CLONE_INDEX, ci, false).unlink();
		root.getContext().refresh(clone.scope);
		#if test
			testCloneRefreshes++;
		#end
	}

}
