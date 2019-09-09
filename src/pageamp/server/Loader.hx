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

package pageamp.server;

import pageamp.react.Value;
import pageamp.core.*;
import pageamp.server.SrcParser;
import pageamp.util.PropertyTool.Props;
import pageamp.web.DomTools;
import pageamp.web.URL;
#if hscriptPos
import pageamp.react.ValueParser;
#end
using StringTools;
using pageamp.util.PropertyTool;
using pageamp.web.DomTools;

//TODO: verifica e logging errori
class Loader {
	public static inline var HIDDEN_COMMENT = '<!---';
	public static inline var HIDDEN_ATTR = '::';

	public static function loadPage(src:SrcDocument,
	                                dst:DomDocument,
	                                rootpath:String,
	                                domain:String,
	                                uri:String,
	                                ?logger:ValueLog): Page {
		dst == null ? dst = DomTools.defaultDocument() : null;
		var ret = loadRoot(dst, src, rootpath, domain, uri, logger);
		return ret;
	}

	public static function loadPage2(text:String,
	                                 ?dst:DomDocument,
	                                 ?logger:ValueLog): Page {
//		text = normalizeText(text);
		var src = SrcParser.parseDoc(text);
		dst == null ? dst = DomTools.defaultDocument() : null;
		var ret = loadRoot(dst, src, null, null, '/', logger);
		return ret;
	}

//	public static function normalizeText(s:String, lineSep='\n'): String {
//		var re2 = ~/\n/;
//		var ret = ~/(\s{2,})/g.map(s, function(re:EReg): String {
//			var p = re.matchedPos();
//			return (re2.matchSub(s, p.pos, p.len) ? lineSep : ' ');
//		});
//		return ret.trim();
//	}

	// =========================================================================
	// private
	// =========================================================================

	static function loadRoot(doc:DomDocument,
	                         src:SrcDocument,
	                         rootpath:String,
	                         domain:String,
	                         uri,
	                         logger:ValueLog): Page {
		var e = src.getRoot();
		var url = new URL(uri);
		url.host = domain;
		var props = loadProps(e, false, logger);
		props.set(Page.FSPATH_PROP, rootpath);
		props.set(Page.URI_PROP, url.toString());
		var ret = new Page(doc, props, function(p:Page) {
			loadChildren(p, e, logger);
		});
		return ret;
	}

	static function loadElement(p:Element,
	                            e:SrcElement,
	                            logger:ValueLog): Element {
		var ret:Element;
		var props = loadProps(e, true, logger);
		ret = switch (e.name) {
			case 'head':
				new Head(p, props);
			case 'body':
				new Body(p, props);
			case Datasource.TAGNAME:
				new Datasource(p, LoaderHelper.loadDataProps(e, props));
			case Define.TAGNAME:
				new Define(p, LoaderHelper.loadDefineProps(props));
			default:
				new Element(p, props);
		}
		loadChildren(ret, e, logger);
		return ret;
	}

	static function loadProps(e:SrcElement,
	                          tagname:Bool,
	                          logger:ValueLog): Props {
		var props:Props = {};
		tagname ? props.set(Element.ELEMENT_TAG, e.name) : null;
		for (a in e.attributes) {
			var key = a.name;
			if (key.startsWith(HIDDEN_ATTR)) {
				continue;
			}
			var val:Dynamic = a.value;
			key.startsWith(Element.CLASS_PFX2) && val == null
					? val = '1'
					: null;
			if ((key = getKey(key)) != null) {
#if hscriptPos
				if (logger != null && !ValueParser.isConstantExpression(val)) {
					val = new ValueRef(val, a, logger);
				}
#end
				props.set(key, val);
			}
		}
		return props;
	}

	static function getKey(key:String): String {
		var ret = key;
		if (key.startsWith(Element.CLASS_PFX2)) {
			key = Element.CLASS_PFX + key.substr(Element.CLASS_PFX2.length);
		} else if (key.startsWith(Element.STYLE_PFX2)) {
			key = Element.STYLE_PFX + key.substr(Element.STYLE_PFX2.length);
		} else if (key.startsWith(Element.EVENT_PFX2)) {
			key = Element.EVENT_PFX + key.substr(Element.EVENT_PFX2.length);
		} else if (key.startsWith(Element.HANDLER_PFX2)) {
			key = Element.HANDLER_PFX + key.substr(Element.HANDLER_PFX2.length);
		} else if (key.startsWith('::')) {
			key = null;
		} else if (key.startsWith(':')) {
			key = key.substr(1);
		} else if (!~/^\w_/.match(key)) {
			key = Element.ATTRIBUTE_PFX + key;
		} else {
			//TODO error logging
		}
		return key;
	}

	static function loadChildren(p:Element, e:SrcElement, logger:ValueLog) {
		for (n in e.nodes) {
			if (Std.is(n, SrcElement)) {
				loadElement(p, untyped n, logger);
			} else if (Std.is(n, SrcText)) {
				if (StringTools.startsWith(untyped n.text, HIDDEN_COMMENT)/* &&
					StringTools.endsWith(untyped n.text, '-->')*/) {
					// nop
				} else {
					loadText(p, untyped n);
				}
			}
		}
	}

	static function loadText(p:Element, n:SrcText): Text {
		var ret = new Text(p, n.text);
		return ret;
	}

}
