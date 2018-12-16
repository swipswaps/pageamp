package pageamp.core;

import pageamp.web.DomTools.DomElement;
import pageamp.util.Set;

/**
* The root Node of a tree is supposed to implement this interface.
**/
interface Root {

	/**
	* Supports one-time initialization of specific Node subclasses.
	* Compared to class initialization, it happens only when and if
	* a specific Node type is actually instantiated.
	* This way, components implemented as Node subclasses can inject their
	* supporting resources (e.g. CSS classes) only if they are actually used.
	**/
	public function typeInit(node:Node, cb:Void->Void): Void;

	public function nextId(): Int;

	public function createDomElement(tagname:String): DomElement;

	public function getDefine(name:String): Define;

	public function setDefine(name:String, def:Define): Void;

	public function getComputedStyle(name:String, ?pseudoElt:String): String;

}

class RootHelper implements Root {
	var currId = 1;
	var initializations(default,null) = new Set<String>();

	public function new() {}

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

	public function createDomElement(tagname:String): DomElement {
		return null;
	}

	public function getDefine(name:String): Define {
		return null;
	}

	public function setDefine(name:String, def:Define): Void {
		// nop
	}

	public function getComputedStyle(name:String, ?pseudoElt:String): String {
		return '';
	}

}