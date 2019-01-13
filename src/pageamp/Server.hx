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

package pageamp;

import pageamp.server.SrcParser;
import haxe.io.Path;
import pageamp.core.Page;
import pageamp.server.Loader;
import pageamp.server.Output;
import pageamp.server.Preprocessor;
import php.Lib;
import php.Web;
import sys.FileSystem;

using pageamp.web.DomTools;
using StringTools;

class Server {

    public static function main() {
	    var params = Web.getParams();
	    var uri = Web.getURI().split('?')[0];
	    var domain = Web.getHostName();
	    var root = './';
	    var re = ~/\.(\w+)$/;
	    var ext = re.match(uri) ? re.matched(1) : null;
	    Log.server('domain: $domain');
	    Log.server('uri: $uri');
	    Log.server('ext: $ext');
	    // 'htm' files are never served (they're page fragments)
	    if (ext != null && ext != 'html') {
		    if (ext != 'htm') {
			    outputFile(root, uri, ext);
		    } else {
			    outputResource(root, '404.html', 404);
		    }
	    } else {
		    ext == 'html' ? uri = uri.split('.$ext')[0] : null;
		    uri.endsWith('/') ? uri = uri + 'index' : null;
		    var page = getPage(root, domain, uri, params);
		    if (maxLevel >= ERR) {
			    outputLog();
		    } else if (page != null) {
			    outputPage(page);
		    } else {
			    outputResource(root, '404.html', 404);
		    }
	    }
    }

	// =========================================================================
	// log()
	// =========================================================================
	public static inline var DEBUG = 1;
	public static inline var TRACE = 2;
	public static inline var WARN = 3;
	public static inline var ERR = 4;
	public static inline var FATAL = 5;
	static var logEntries = new Array<LogEntry>();
	static var maxLevel = 0;

	public static inline function debug(msg:String) log(DEBUG, msg);
	public static inline function trace(msg:String) log(TRACE, msg);
	public static inline function warn(msg:String) log(WARN, msg);
	public static inline function err(msg:String) log(ERR, msg);
	public static inline function fatal(msg:String) log(FATAL, msg);

	public static function log(level:Int, msg:String) {
		level > maxLevel ? maxLevel = level : null;
		logEntries.push({level:level, msg:msg});
	}

	static function outputLog() {
		Web.setHeader('Content-type', 'text/plain');
		for (e in logEntries) {
			Lib.print(switch (e.level) {
  				case DEBUG: 'DEBUG ';
				case TRACE: 'TRACE ';
				case WARN: 'WARN ';
				case ERR: 'ERR ';
				case FATAL: 'FATAL ';
				default: 'UNKNOWN ';
			});
			Lib.println(e.msg);
		}
	}

	// =========================================================================
	// outputFile()
	// =========================================================================

	// http://en.wikipedia.org/wiki/Internet_media_type
	static function outputFile(root:String, uri:String, ext:String) {
		try {
			Web.setHeader('Content-type', switch (ext) {
				case 'js': 'application/javascript';
				case 'json': 'application/json';
				case 'xml': 'application/xml';
				case 'txt': 'text/plain';
				case 'css': 'text/css';
				//TODO
				default: 'text/html';
			});
			Lib.printFile(root + uri);
		} catch (e:Dynamic) {
			outputResource(root, '404.html', 404);
		}
	}

	// =========================================================================
	// outputResource()
	// =========================================================================

	static function outputResource(root:String, fname:String, code=200) {
		Web.setReturnCode(code);
		Lib.printFile('.pageamp/res/' + fname);
	}

	// =========================================================================
	// outputPage()
	// =========================================================================

	static function getPage(root:String,
	                        domain:String,
	                        uri:String,
	                        params:Map<String,String>): Page {
		var ret:Page = null;
		var src:SrcDocument = null;
		//uri = uri.replace('%20', ' ');
		Log.server('getPage($root, $uri)');
		try {
			var p = new Preprocessor(Web.getCwd());
			src = p.loadFile(uri);
		} catch (e:Dynamic) {
			Log.server('getPage(): ' + e);
			if (!uri.endsWith('/')
				&& FileSystem.exists(root + uri)
				&& FileSystem.isDirectory(root + uri)) {
				Web.redirect(uri + '/');
			} else {
				err(e + '');
			}
		}
		try {
			var path = new Path(root + uri);
			var page = Loader.loadPage(src, null, path.dir, domain, Web.getURI());
			var redirect = page.get('pageRedirect');
			if (redirect != null) {
				Web.redirect(redirect);
			} else {
				var ua = getUserAgent();
				Output.addClient(page, ua);
				ret = page;
			}
		} catch (e:Dynamic) {
//			outputResource(root, '404.html', 404);
			err(e + '');
		}
		return ret;
	}

	static function getUserAgent() : String {
		var ua = null;
		try {
			ua = untyped __php__("$_SERVER['HTTP_USER_AGENT']");
		} catch (ignored:Dynamic) {}
		return ua;
	}

	static inline function outputPage(page:Page) {
		Web.setHeader('Content-type', 'text/html');
		Lib.println('<!DOCTYPE html>');
		Lib.print(page.doc.domRootElement().domMarkup());
	}

}

typedef LogEntry = {
	var level: Int;
	var msg: String;
}