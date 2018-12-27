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

package pageamp.server;

import hscript.Expr;
import htmlparser.HtmlParser;
import htmlparser.HtmlParser;
import pageamp.server.SrcParser;
import htmlparser.*;

class SrcParser extends HtmlParser {
	public static inline var NODE_POS = 0;
	public static inline var NAME_POS = 1;
	public static inline var VALUE_POS = 2;
	static var patched = false;
	public var pathname:String;

	static function patch() {
		// bbmark: allow one or more ':' as an id prefix and inhibit
		// XML-style namespacing
		HtmlParser.reNamespacedID = ":*[a-z](?:-?[_a-z0-9])*";

		HtmlParser.reCDATA = "[<]!\\[CDATA\\[[\\s\\S]*?\\]\\][>]";
		HtmlParser.reScript = "[<]\\s*script\\s*([^>]*)>([\\s\\S]*?)"
				+ "<\\s*/\\s*script\\s*>";
		HtmlParser.reStyle = "<\\s*style\\s*([^>]*)>([\\s\\S]*?)"
				+ "<\\s*/\\s*style\\s*>";
		HtmlParser.reElementOpen = "<\\s*(" + HtmlParser.reNamespacedID + ")";
		HtmlParser.reAttr = HtmlParser.reNamespacedID
				+ "(?:\\s*=\\s*(?:'[^']*?'|\"[^\"]*?\"|[-_a-z0-9]+))?";
		HtmlParser.reElementEnd = "(/)?\\s*>";
		HtmlParser.reElementClose = "<\\s*/\\s*("
				+ HtmlParser.reNamespacedID + ")\\s*>";
		HtmlParser.reComment = "<!--[\\s\\S]*?-->";

		HtmlParser.reMain = new EReg("(" + HtmlParser.reCDATA + ")|("
				+ HtmlParser.reScript + ")|(" + HtmlParser.reStyle + ")|("
				+ HtmlParser.reElementOpen + "((?:\\s+"
				+ HtmlParser.reAttr +")*)\\s*" + HtmlParser.reElementEnd
				+ ")|(" + HtmlParser.reElementClose + ")|("
				+ HtmlParser.reComment + ")", "ig");

		HtmlParser.reParseAttrs = new EReg("(" + HtmlParser.reNamespacedID
				+ ")(?:\\s*=\\s*('[^']*'|\"[^\"]*\"|[-_a-z0-9]+))?" , "ig");

		patched = true;
	}

	public static function parseDoc(s:String, ?pathname:String): SrcDocument {
		!patched ? patch() : null;
		return new SrcDocument(s, true, new SrcParser(pathname));
	}

	public function new(?pathname:String) {
		this.pathname = pathname;
		super();
	}

	public static function valueLogger(err:Error, attr:Dynamic) {
		var a:SrcAttribute = cast attr;
	}

	// =========================================================================
	// private
	// =========================================================================

	override function processMatches(openedTagsLC:Array<String>) : {
		nodes:Array<HtmlNode>, closeTagLC:String
	} {
		var nodes = new Array<HtmlNode>();
		var prevEnd = i > 0
				? matches[i - 1].allPos + matches[i - 1].all.length
				: 0;
		var curStart = matches[i].allPos;
		if (prevEnd < curStart) {
			nodes.push(new SrcText(str.substr(prevEnd, curStart - prevEnd),
					this, i));
		}
		while (i < matches.length) {
			var m = matches[i];
			if (m.elem != null && m.elem != "") {
				var ee = parseElement(openedTagsLC);
				nodes.push(ee.element);
				if (ee.closeTagLC != "") return {
					nodes:nodes, closeTagLC:ee.closeTagLC
				};
			} else if (m.script != null && m.script != "") {
				var scriptNode = newElement("script", procAttrs(m.scriptAttrs));
				scriptNode.addChild(new SrcText(m.scriptText, this, i));
				nodes.push(scriptNode);
			} else if (m.style != null && m.style != "") {
				var styleNode = newElement("style", procAttrs(m.styleAttrs));
				styleNode.addChild(new SrcText(m.styleText, this, i));
				nodes.push(styleNode);
			} else if (m.close != null && m.close != "") {
				if (m.tagCloseLC == openedTagsLC[openedTagsLC.length - 1]) break;
				if (tolerant) {
					if (openedTagsLC.lastIndexOf(m.tagCloseLC) >= 0) break;
				} else {
					throw new HtmlParserException("Closed tag <" + m.tagClose
							+ "> doesn't match to open tag <"
							+ openedTagsLC[openedTagsLC.length - 1] + ">.",
							getPosition(i));
				}
			} else if (m.comment != null && m.comment != "") {
				nodes.push(new SrcText(m.comment, this, i));
			} else {
				throw new HtmlParserException("Unexpected XML node.",
											  getPosition(i));
			}
			if (tolerant && i >= matches.length) break;
			var curEnd = matches[i].allPos + matches[i].all.length;
			var nextStart = i + 1 < matches.length
					? matches[i + 1].allPos
					: str.length;
			if (curEnd < nextStart) {
				nodes.push(new SrcText(str.substr(curEnd, nextStart - curEnd),
									   this, i));
			}
			i++;
		}
		return { nodes:nodes, closeTagLC:"" };
	}

	override function parseElement(openedTagsLC:Array<String>): {
		element:HtmlNodeElement, closeTagLC:String
	} {
		var tag = matches[i].tagOpen;
		var tagLC = matches[i].tagOpenLC;
		var attrs = matches[i].attrs;
		var isWithClose = matches[i].tagEnd != null
				&& matches[i].tagEnd != ""
				|| isSelfClosingTag(tagLC);
		var elem = newElement(tag, procAttrs(attrs));
		var closeTagLC = "";
		if (!isWithClose) {
			i++;
			openedTagsLC.push(tagLC);
			var m = processMatches(openedTagsLC);
			for (node in m.nodes) elem.addChild(node);
			openedTagsLC.pop();
			closeTagLC = m.closeTagLC != tagLC ? m.closeTagLC : "";
			if (i < matches.length || !tolerant) {
				if (matches[i].close == null
						|| matches[i].close == ""
						|| matches[i].tagCloseLC != tagLC) {
					if (!tolerant) {
						throw new HtmlParserException("Tag <" + tag
								+ "> not closed.", getPosition(i));
					} else {
						closeTagLC = matches[i].tagCloseLC;
					}
				}
			}
		}
		return { element:elem, closeTagLC:closeTagLC };
	}

	override function newElement(name:String,
	                             attrs:Array<HtmlAttribute>): HtmlNodeElement {
		return new SrcElement(name, attrs, this, i);
	}

	override function getPosition(matchIndex:Int): {
		line:Int, column:Int, length:Int
	} {
		var m = matches[matchIndex];
		var line = 1;
		var column = 1;
		var i = 0; while (i < m.allPos) {
			var chars = i + 1 < str.length
					? str.substring(i, i + 2)
					: str.charAt(i);
			if (chars == "\r\n") {
				i += 2; line++; column = 1;
			} else if (chars.charAt(0) == "\n" || chars.charAt(0) == "\r") {
				i++; line++; column = 1;
			} else {
				i++; column++;
			}
		}
		return {line:line, column:column, length:m.all.length};
	}

	function procAttrs(str:String): Array<HtmlAttribute> {
		var attributes = new Array<HtmlAttribute>();
		var pos = 0;
		while (pos < str.length && HtmlParser.reParseAttrs.matchSub(str, pos)) {
			var name = HtmlParser.reParseAttrs.matched(1);
			var value = HtmlParser.reParseAttrs.matched(2);
			var quote : String = null;
			var unescaped : String = null;
			if (value != null) {
				quote = value.substr(0, 1);
				if (quote == '"' || quote == "'") {
					value = value.substr(1, value.length - 2);
				} else {
					quote = "";
				}
				unescaped = HtmlTools.unescape(value);
			}
			var p = HtmlParser.reParseAttrs.matchedPos();
			attributes.push(new SrcAttribute(name, unescaped, quote, p));
			pos = p.pos + p.len;
		}
		return attributes;
	}

	function updatePos(i:Int, i0=0, ?p:SrcPos): SrcPos {
		p == null ? p = new SrcPos(1, 1, 0) : null;
		p.pathname = pathname;
		while (i0 < i) {
			var chars = i0 + 1 < str.length
					? str.substring(i0, i0 + 2)
					: str.charAt(i0);
			if (chars == '\r\n') {
				i0 += 2; p.line++; p.column = 1;
			} else if (chars.charAt(0) == '\n' || chars.charAt(0) == '\r') {
				i0++; p.line++; p.column = 1;
			} else {
				i0++; p.column++;
			}
		}
		return p;
	}

}

class SrcPos {
	public var line: Int;
	public var length: Int;
	public var column: Int;
	public var pathname: String;

	public function new(line:Int, column:Int, length:Int, ?pathname:String) {
		this.line = line;
		this.column = column;
		this.length = length;
		this.pathname = pathname;
	}

	public function toString(): String {
		return '$pathname:$line: character $column';
	}
}

typedef AttrPos = {
	pos: Int, len: Int,
}

@:access(htmlparser.HtmlParser)
class SrcDocument extends HtmlDocument {
	public var parser(default,null): SrcParser;

	public function new(str="", tolerant=false, ?parser:SrcParser) {
		super();
		this.parser = (parser != null ? parser : new SrcParser());
		var nodes = this.parser.parse(str, tolerant);
		for (node in nodes) {
			addChild(node);
		}
	}

	public inline function getRoot(): SrcElement {
		return cast children[0];
	}

}

class SrcElement extends HtmlNodeElement {
	public var p(default,null): SrcParser;
	public var i(default,null): Int;

	@:access(pageamp.server.SrcAttribute)
	public function new(name:String, attributes:Array<HtmlAttribute>,
	                    p:SrcParser, i:Int) {
		this.p = p;
		this.i = i;
		super(name, attributes);
		var srcAtts:Array<SrcAttribute> = cast attributes;
		for (a in srcAtts) {
			a.e = this;
		}
	}

	public inline function nthElement(index:Int): SrcElement {
		return cast children[index];
	}

	public inline function nthNode(index:Int): SrcText {
		return cast nodes[index];
	}

	public inline function nthAttribute(index:Int): SrcAttribute {
		return cast attributes[index];
	}

	@:access(pageamp.server.SrcParser)
	public function getPos(): SrcPos {
		var ret:SrcPos = cast p.getPosition(i);
		ret.pathname = p.pathname;
		return ret;
	}

}

class SrcText extends HtmlNodeText {
	public var p(default,null): SrcParser;
	public var i(default,null): Int;

	public function new(text:String, p:SrcParser, i:Int) {
		this.p = p;
		this.i = i;
		super(text);
	}

	@:access(pageamp.server.SrcParser)
	public function getPos(offset=0): SrcPos {
		var m1 = i > 0 ? p.matches[i - 1] : null;
		var p1 = i > 0 ? p.getPosition(i - 1) : {line:1, length:0, column:1};
		var m2 = p.matches[i];
		var p2 = p.getPosition(i);
		var line = p1.line;
		var column = p1.column;
		var j = 0;
		while (j < p1.length) {
			var chars = j + 1 < m1.all.length
					? m1.all.substring(j, j + 2)
					: m1.all.charAt(j);
			if (chars == "\r\n") {
				j += 2; line++; column = 1;
			} else if (chars.charAt(0) == "\n" || chars.charAt(0) == "\r") {
				j++; line++; column = 1;
			} else {
				j++; column++;
			}
		}
		var ret = new SrcPos(line,
				column,
				m2.allPos - (m1 != null ? m1.allPos + m1.all.length: 0),
				p.pathname);
		if (offset > 0) {
			var i = m1.allPos + p1.length;
			p.updatePos(i + offset, i, ret);
			ret.length -= offset;
		}
		return ret;
	}

}

class SrcAttribute extends HtmlAttribute {
	public var e(default,null): SrcElement;
	public var p(default,null): AttrPos;

	public function new(name:String, value:String, quote:String, p:AttrPos) {
		this.p = p;
		super(name, value, quote);
	}

	/**
	* `offset` == null: attribute name pos
	* `offset` >= 0: attribute value pos
	**/
	@:access(pageamp.server.SrcParser, htmlparser.HtmlParser)
	public function getPos(?offset:Int): SrcPos {
		var m = e.p.matches[e.i];
		var i0 = m.allPos;
		var re = new EReg(HtmlParser.reElementOpen, 'ig');
		if (re.matchSub(e.p.str, m.allPos)) {
			i0 += re.matched(0).length;
		}
		var ret = e.p.updatePos(i0 + p.pos);
		ret.length = p.len;
		if (offset != null) {
			var re = ~/["']/;
			if (re.matchSub(e.p.str, i0 + p.pos, p.len)) {
				var i = re.matchedPos().pos;
				ret = e.p.updatePos(i + 1 + offset);
				ret.length = i0 + p.pos + p.len - 2 - i - offset;
			} else {
				ret.column += name.length;
				ret.length = 0;
			}
		}
		return ret;
	}

}
