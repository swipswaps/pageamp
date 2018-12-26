package pageamp.core;

import pageamp.util.PropertyTool;
import pageamp.web.DomTools;
import pageamp.react.Value;
import pageamp.util.BaseNode;

using pageamp.web.DomTools;

class Text extends Node {
	public static inline var TEXT_PROP = Node.NODE_PFX + 'text';
	public var value(default,null): Value;
	public var text(default,null): String;

	public function new(parent:Node, text:String,
	                    ?n:DomTextNode, ?plug:String, ?index:Int) {
		this.text = text;
		this.node = n;
		this.plug = plug;
		this.index = index;
		var props:Props = null;
		plug != null ? props = props.set(Node.NODE_PLUG, plug) : null;
		index != null ? props = props.set(Node.NODE_INDEX, index) : null;
		super(parent, props);
		if (isDynamicValue(null, text)) {
			if (parentWithNonNullProp(Element.FOREACH_PROP) == null) {
				var scope = getScope();
				if (scope != null) {
					value = scope.set(Node.NODE_PFX + root.nextId(), text);
					value.cb = textValueCB;
				}
			}
		} else {
			textValueCB(null, null, text);
		}
	}

	// =========================================================================
	// abstract methods
	// =========================================================================

	override public function getDomNode(): DomNode {
		return t;
	}

	override public function cloneTo(parent:Node, nesting:Int, ?index:Int): Node {
		var clone = new Text(cast parent, text, plug, this.index);
		return clone;
	}

	// =========================================================================
	// private
	// =========================================================================
	var node: DomTextNode;
	var plug: String;
	var index: Int;
	var t: DomTextNode;

	override function init() {
		super.init();
		t = (node != null ? node : root.createDomTextNode(''));
	}

	@:access(pageamp.core.Element)
	override function wasAdded(logicalParent:BaseNode,
	                           parent:BaseNode,
	                           ?i:Int) {
		if (node == null) {
			var p:Element = cast parent;
			var b:Node = (i != null ? p.children[i] : null);
			p.dom.domAddChild(t, b != null ? b.getDomNode() : null);
		}
	}

	override function wasRemoved(logicalParent:BaseNode, parent:BaseNode) {
		t.domRemove();
	}

	function textValueCB(u, n, v:Dynamic) {
		var s = (v != null ? Std.string(v) : '');
		t.domSetText(s);
	}

}
