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

import htmlparser.*;

class SrcParser extends HtmlParser {
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

	public function getPos(n:Dynamic): SrcPos {
		var ret:SrcPos = null;
		if (Std.is(n, SrcElement)) {
			ret = cast getPosition(n.i);
		} else if (Std.is(n, SrcText)) {
			var i = cast(n, SrcText).i;
			var m1 = i > 0 ? matches[i - 1] : null;
			var p1 = i > 0 ? getPosition(i - 1) : {line:1, length:0, column:1};
			var m2 = matches[i];
			var p2 = cast getPosition(i);
			var line = p1.line;
			var column = p1.column;
			var j = 0;
			while (j < p1.length) {
				var chars = j + 1 < m1.all.length
						? m1.all.substring(j, j + 2)
						: m1.all.charAt(j);
				if (chars == "\r\n") {
					j += 2;
					line++;
					column = 1;
				} else if (chars.charAt(0) == "\n" || chars.charAt(0) == "\r") {
					j++;
					line++;
					column = 1;
				} else {
					j++;
					column++;
				}
			}
			ret = {
				line: line,
				column: column,
				length: m2.allPos - (m1 != null ? m1.allPos + m1.all.length: 0)
			}
		} else if (Std.is(n, SrcAttribute)) {
			//TODO
		} else {
			ret = {line:1, length:0, column:1};
		}
		return ret;
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
			nodes.push(new SrcText(str.substr(prevEnd, curStart - prevEnd), i));
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
				var scriptNode = newElement("script", _parseAttrs(m.scriptAttrs));
				scriptNode.addChild(new SrcText(m.scriptText, i));
				nodes.push(scriptNode);
			} else if (m.style != null && m.style != "") {
				var styleNode = newElement("style", _parseAttrs(m.styleAttrs));
				styleNode.addChild(new SrcText(m.styleText, i));
				nodes.push(styleNode);
			} else if (m.close != null && m.close != "") {
				if (m.tagCloseLC == openedTagsLC[openedTagsLC.length - 1]) break;
				if (tolerant) {
					if (openedTagsLC.lastIndexOf(m.tagCloseLC) >= 0) break;
				} else {
					throw new HtmlParserException("Closed tag <" + m.tagClose
							+ "> don't match to open tag <"
							+ openedTagsLC[openedTagsLC.length - 1] + ">.",
							getPosition(i));
				}
			} else if (m.comment != null && m.comment != "") {
				nodes.push(new SrcText(m.comment, i));
			} else {
				throw new HtmlParserException("Unexpected XML node.", getPosition(i));
			}
			if (tolerant && i >= matches.length) break;
			var curEnd = matches[i].allPos + matches[i].all.length;
			var nextStart = i + 1 < matches.length
					? matches[i + 1].allPos
					: str.length;
			if (curEnd < nextStart) {
				nodes.push(new SrcText(str.substr(curEnd, nextStart - curEnd), i));
			}
			i++;
		}
		return { nodes:nodes, closeTagLC:"" };
	}

	override function newElement(name:String,
	                             attributes:Array<HtmlAttribute>): HtmlNodeElement {
		return new SrcElement(name, attributes, i);
	}

	function _parseAttrs(str:String): Array<HtmlAttribute> {
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
			attributes.push(new HtmlAttribute(name, unescaped, quote));
			var p = HtmlParser.reParseAttrs.matchedPos();
			pos = p.pos + p.len;
		}
		return attributes;
	}

}

typedef SrcPos = {
	line: Int, length: Int, column: Int, ?pathname: String,
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

	public function getPos(n:Dynamic): SrcPos {
		return (parser != null ? parser.getPos(n) : null);
	}

}

class SrcElement extends HtmlNodeElement {
	public var i(default,null): Int;

	public function new(name:String, attributes:Array<HtmlAttribute>, i:Int) {
		this.i = i;
		super(name, attributes);
	}

}

class SrcText extends HtmlNodeText {
	public var i(default,null): Int;

	public function new(text:String, i:Int) {
		this.i = i;
		super(text);
	}

}

class SrcAttribute extends HtmlAttribute {
	public var i(default,null): Int;

	public function new(name:String, value:String, quote:String, i:Int) {
		this.i = i;
		super(name, value, quote);
	}

}