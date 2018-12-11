package pageamp.core;

import pageamp.util.Set;

class Page extends Element {
	public var initializations(default,null) = new Set<String>();
	public var defines(default,null) = new Map<String, Define>();

	#if !debug inline #end
	public function nextId(): Int {
		return currId++;
	}

	// =========================================================================
	// private
	// =========================================================================
	var currId = 1;

}
