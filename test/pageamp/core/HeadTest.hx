package pageamp.core;

import haxe.unit.TestCase;
import pageamp.core.Element;
import pageamp.core.Head;
import pageamp.core.ElementTest;

using StringTools;
using pageamp.web.DomTools;

class HeadTest extends TestCase {

	function testHead1() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: 'body {color:blue}',
		});
		assertEquals('<html><head>'
		+ '<style>body {color:blue}</style></head>'
		+ '<body></body></html>', root.doc.domToString());
	}

	function testHeadApiVendorize() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			//TODO: trailing space is needed otherwise it's mistakenly taken for
			//an all-scripting expression because of the closing curly bracket
			innerText: "body {${cssVendorize('color:blue')}} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color:blue;\n'
		+ '-moz-color:blue;\n'
		+ '-webkit-color:blue;\n'
		+ '-ms-color:blue;} </style>'
		+ '</head><body></body></html>', root.doc.domToString());
	}

	function testHeadApiGoogleFont() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {font-family:${cssGoogleFont('Lato:400,700')};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<link rel="stylesheet" type="text/css"'
		+ ' href="https://fonts.googleapis.com/css?family=Lato:400,700">'
		+ '<style>body {font-family:"Lato";} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiMakeSelectable() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {${cssMakeSelectable()}} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {-webkit-touch-callout:text;-webkit-user-select:text;'
		+ '-khtml-user-select:text;-moz-user-select:text;'
		+ '-ms-user-select:text;user-select:text;} </style>'
		+ '</head><body></body></html>', root.doc.domToString());
	}

	function testHeadApiMakeNonSelectable() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {${cssMakeNonSelectable()}} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {-webkit-touch-callout:none;-webkit-user-select:none;'
		+ '-khtml-user-select:none;-moz-user-select:none;'
		+ '-ms-user-select:none;user-select:none;} </style>'
		+ '</head><body></body></html>', root.doc.domToString());
	}

	function testHeadApiMakeVGradient() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {${cssMakeVGradient('#222', '#444')}} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ "<style>body {background-color:#222222;"
		+ "filter:progid:DXImageTransform.Microsoft.gradient"
		+ "(startColorstr='#222222', endColorstr='#444444');"
		+ "background:-webkit-gradient"
		+ "(linear, left top, left bottom, from(#222222), to(#444444));"
		+ "background:-moz-linear-gradient(top, #222222, #444444);} </style>"
		+ '</head><body></body></html>', root.doc.domToString());
	}

	function testHeadApiMakeShadow() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {${cssMakeShadow()}} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {-moz-box-shadow:0px 0px 0px #000;'
		+ '-webkit-box-shadow:0px 0px 0px #000;'
		+ '-box-shadow:0px 0px 0px #000;box-shadow:0px 0px 0px #000;} </style>'
		+ '</head><body></body></html>', root.doc.domToString());
	}

	function testHeadApiMakeInsetShadow() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {${cssMakeInsetShadow()}} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {-moz-box-shadow:0px 0px 4px #000 inset;\n'
		+ '-webkit-box-shadow:0px 0px 4px #000 inset;\n'
		+ '-box-shadow:0px 0px 4px #000 inset;\n'
		+ 'box-shadow:0px 0px 4px #000 inset} </style>'
		+ '</head><body></body></html>', root.doc.domToString());
	}

	function testHeadApiFullRgb() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssFullRgb('#444')};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #444444;} </style>'
		+ '</head><body></body></html>', root.doc.domToString());
	}

	function testHeadApiColor2Components() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssColor2Components('#444')};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: { r : 68, g : 68, b : 68, a : null };} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiComponents2Color() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: "
			+ "${cssComponents2Color(cssColor2Components('#444'))}"
			+ ";} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #444444;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiColorOffset1() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssColorOffset('#444', 0, 1)};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #444444;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiColorOffset2() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssColorOffset('#444', 17, 1)};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #555555;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiColorOffset3() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssColorOffset('#345', 0, 0)};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #444444;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiColorOffset4() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssColorOffset('#345', 0, 0, .5)};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: rgba(68,68,68,0.5);} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiCounterColor1() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssCounterColor('#ccc')};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: black;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiCounterColor2() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssCounterColor('#444')};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: white;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiCounterColor3() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssCounterColor('#ccc', '#222')};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #222;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiCounterColor4() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: ${cssCounterColor('#444', '', '#ddd')};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #ddd;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiCounterColor5() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: "
			+ "${cssCounterColor('#888', '#000', '#fff', 128)};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #000;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiCounterColor6() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: "
			+ "${cssCounterColor('#888', '#000', '#fff', 200)};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #fff;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	function testHeadApiColorMix1() {
		var root = new TestRootElement(TestAll.getDoc());
		var head = new Head(root);
		var s = new Element(head, {
			n_tag: 'style',
			innerText: "body {color: "
			+ "${cssColorMix('#987', '#789', .5)};} ",
		});
		root.refresh();
		assertEquals('<html><head>'
		+ '<style>body {color: #888888;} </style>'
		+ '</head><body></body></html>', norm(root.doc.domToString()));
	}

	// =========================================================================
	// util
	// =========================================================================

	function norm(s:String) {
		s = ~/(\s+)/g.replace(s, ' ');
		return s.replace(' />', '>');
	}

}
