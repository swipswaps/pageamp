package pageamp;

import haxe.macro.Expr;

class Log {

	macro public static function value(e:Expr) {
#if (debug && logValue)
		return macro trace('Value - ' + $e);
#else
		return macro null;
#end
	}

	macro public static function valueParser(e:Expr) {
#if (debug && logValueParser)
		return macro trace('ValueParser - ' + $e);
#else
		return macro null;
#end
	}

	macro public static function valueInterp(e:Expr) {
#if (debug && logValueInterp)
		return macro trace('ValueInterp - ' + $e);
#else
		return macro null;
#end
	}

}
