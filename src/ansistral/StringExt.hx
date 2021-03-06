package ansistral;

using StringTools;
using ansistral.StringExt;

#if tink_core
import tink.core.Pair;
import tink.core.Outcome;
#end

/**
 * Additional methods to String.
 * Public domain (copyleft) grepsuzette
 */
class StringExt {

    /**
     * "sun/moon".until("/") gives "sun".
     * With Haxe 4 it works correctly with unicode.
     */
    public static function until(s:String, m:String):String {
        var i = s.indexOf(m);
        return i == -1 
            ? s
            : s.substr(0, i)
        ;
    }

    /**
     * "sun/moon".after("/") gives "moon". 
     * An empty String is returned if no occurence was found.
     * With Haxe 4 it works correctly with unicode.
     */
    public static function after(s:String, m:String):String {
        var i = s.indexOf(m);
        return (i == -1) 
            ? ""
            : s.substr(i + 1)
        ;
    }

    /**
     * "sun/moon/earth".afterLast("/") gives "earth". 
     * An empty String is returned if no occurence was found.
     * With Haxe 4 it works correctly with unicode.
     */
    public static function afterLast(s:String, m:String):String {
        var i = s.lastIndexOf(m);
        return (i == -1) 
            ? ""
            : s.substr(i + 1)
        ;
    }

    /**
     * "sun/moon/earth".untilLast("/") gives "sun/moon".
     * With Haxe 4 it works correctly with unicode.
     */
    public static function untilLast(s:String, m:String):String {
        var i = s.lastIndexOf(m);
        return i == -1 
            ? s
            : s.substr(0, i)
        ;
    }

    /**
     * "\t".times(3) gives 3 tabulations.
     **/
    public static inline function times(s:String, n:Int):String return repeat(s,n);
    public static function repeat(s:String, n:Int):String {
        if (n <= 0) return "";
        var r = new StringBuf();
        for (i in 0...n) r.add(s);
        return r.toString();
    }



	public static function endsWith(s:String, sub:String):Bool {
        #if haxe4 return StringTools.endsWith(s, sub);
        #else return sub.length == 0 || s.lastIndexOf(sub) == s.length - sub.length;
        #end
	}

	/**
	 * Trim any of those caracters at the beginning or end of the string.
     * Beware it is made to work with Ascii, not utf-8, has not been tested
     * with it.
	 * @param (String s) The string
	 * @param (String chars) The caracteres, eg ";,. "
	 * @return (String) the new trimmed string
	 */
	public static function trimChars(s:String, chars:String):String {
        if (s == null) throw "null string in trimChars()";
        if (s.length == 0) return "";
        if (chars == null || chars.length == 0) return s;

        var trimCodes : Array<Int> = inline codes(chars);
        var iStart = -1;
        var iEnd = s.length;
        var char : Int = -1;

        var i = iStart;
        while (++i < s.length) { // find iStart
            char = s.fastCodeAt(i);
            var bFound = false;
            for (c in trimCodes) if (char == c) { bFound = true; break; }
            if (!bFound) break;
        }
        iStart = i;
        
        i = iEnd;
        while (--i >= 0) { // find iEnd
            char = s.fastCodeAt(i);
            var bFound = false;
            for (c in trimCodes) if (char == c) bFound = true;  
            if (!bFound) break;
        }
        iEnd = i;

        return s.substring(iStart, iEnd + 1);
	}

    public static function trim(s:String) : String return StringTools.trim(s);

	/**
	 * Strip off the end of a string if required 
	 */
	public static function stripExt(s:String, toStrip:String):String {
		var l = s.length - toStrip.length;
		return s.substr(l) == toStrip ? s.substr(0, l) : s;
	}

	/**
	 * Strip off the file
	 */
	// public static function stripExt(s:String, toStrip:String):String {
	// 	var l = s.length - toStrip.length;
	// 	return s.substr(l) == toStrip ? s.substr(0, l) : s;
	// }
	
	/**
	 * Strip off the begining or base of a string if required 
	 */
	public static function stripBase(s:String, toStrip:String):String {
		return s.indexOf(toStrip) == 0 ? s.substr(toStrip.length) : s;
	}

    /**
     * Strip most common roman alphabet accents.
     * This is a WIP.
     */
    public static function stripAccents(s:String) : String {
        var buf = new StringBuf();
        for (i in 0...s.length) {
            buf.add(switch s.charAt(i) {
                // These hopefully should cover most latin languages:
                //   english, french, german, dutch, 
                //   italian, portuguese, spanish, swedish, catalan,
                //   lithuanian(is it latin?), maltese, welsch
                // https://en.wikipedia.org/wiki/Diacritic#Other_languages

                // grave  circ  acute caron macron diae tild
                case "á" | "â" | "à" | "ǎ" | "ā" | "ä"  | "ã": "a";
                case "é" | "ê" | "è" | "ě" | "ē" | "ë"       : "e";
                case "í" | "î" | "ì" | "ǐ" | "ī" | "ï"       : "i";
                case "ó" | "ô" | "ò" | "ǒ" | "ō" | "ö"  | "õ": "o";
                case "ú" | "û" | "ù" | "ǔ" | "ū" | "ü"       : "u";
                case "ẃ" | "ŵ" | "ẁ" |             "ẅ"       : "w"; // welsch 
                case "ý" | "ŷ" | "ỳ" | /**/        "ÿ"       : "y";
                case "Á" | "Â" | "À" | "Ǎ" | "Ā" | "Ä"  | "Ã": "A";
                case "É" | "Ê" | "È" | "Ě" | "Ē" | "Ë"       : "E";
                case "Í" | "Î" | "Ì" | "Ǐ" | "Ī" | "Ï"       : "I";
                case "Ó" | "Ô" | "Ò" | "Ǒ" | "Ō" | "Ö"  | "Õ": "O";
                case "Ú" | "Û" | "Ù" | "Ǔ" | "Ū" | "Ü"       : "U";
                case "Ý" | "Ŷ" | "Ỳ" | /**/        "Ÿ"       : "Y";
                case "Ẃ" | "Ŵ" | "Ẁ" |             "Ẅ"       : "W"; // welsch
                case "å": "a";    // a WITH RING ABOVE (as in swedish)
                case "Å": "A";    // A WITH RING ABOVE (as in swedish)
                case "ñ": "n";
                case "š": "s";    // carons in s and z appear in finnish
                case "ž": "z";    // carons in s and z appear in finnish
                case "¿" | "⋅": "";
                case "Œ": "Oe";
                case "œ": "oe";
                case "Æ": "Ae";
                case "æ": "ae";
                case "ç": "c";
                case "ß": "ss";
                case xxx : xxx;
            });
        }
        return buf.toString();
    }

    /**
     * Given String, split it into a Pair upon `charcode`, or fail.
     * This requires the String to contain exactly 1 occurence of char.
     * Only defined if tink_core is used.
     * E.g. var out : Outcome<Pair, String> = "AAPL/USD".splitUpon("/");
     * switch out {
     *   case Success(pair): trace
     *   case Failure(sErr): trace("error: " + sErr);
     * }
     */
    #if tink_core
    public static function splitUpon(s:String, char:String) : tink.core.Outcome<tink.core.Pair<String,String>, String> {
        if (s == null) return Failure('cant splitUpon(null, $char)');
        if (char == null || char.length != 1) return Failure('cant splitUpon() because $char len !=1');
        var i = s.indexOf(char);
        if (i <= 0) return Failure('can splitUpon($s, $char)');
        else return Success(new tink.core.Pair(s.substr(0, i), s.substr(i + 1)));
    }
    #end

	/**
	 * Forces sign in the result String, e.g. when `n` in >0, we get "+`n`".
	 * @param (n) The number.
	 * @param (Bool disableZero) Whether to show nothing if n == 0
	 * Example:
	 * -5 -> "-5"
	 *  0 -> "0"   (when disableZero=false)
	 *  0 -> ""    (when disableZero=true)
	 *  5 -> "+5"
	 */
	public static function formatSignedString(
        n           : Int,
        disableZero : Bool=false
	) : String {
		if (n == 0) return disableZero ? "" : "0";
        else if (n > 0) return "+" + n;
        else return Std.string(n);
	}

	/**
	 * Convert a string to an array of ascii codes.
	 * @param (String) 
	 * @return (Array<Int>)
	 */
	public static function codes(s:String):Array<Int> 
		return [ for (i in 0...s.length) s.fastCodeAt(i) ];
	

	/**
     * Append n times to a string. Useful whenever string to append is more
     * than 1 char, otherwise use rpad()
	 * @sa rpadSpecial()
	 */
	public static function appendN(original:String, append:String, n:Int) :String {
		var s = new StringBuf();
        s.add(original);
		for (i in 0...n) s.add(append);
		return s.toString();
	}

	/**
     * Pad a string, but even if append takes more than 1 character, pretend it
     * takes only 1. Useful for padding "&nbsp;".
	 * @param (pretendOriginalLength) 
	 	if > 0, will be used instead of original.length. 
        if < 0, will be substracted from original.length. To use if you have
        some HTML inside original, eg <i>toto</i> 
	 */
	public static function rpadSpecial(
        original:String,
        append:String,
        n:Int,
        pretendOriginalLength:Int=0
	):String {
		var buf = new StringBuf();
        buf.add(original);
		var len = original.length;
		if (pretendOriginalLength > 0) len = pretendOriginalLength;
		else if (pretendOriginalLength < 0) len += pretendOriginalLength; // += bc it's negative
		for (i in len ... n) buf.add(append);
		return buf.toString();
	}

	/**
     * Whether the first character of `s` is one of the chars in `chars`.
	 * e.g. 'bleu'.startsWithOneOf('aeiouy') -> false
	 *      'bleu'.startsWithOneOf('B', false) -> false
	 *      'bleu'.startsWithOneOf('B', true) -> true
	 *      'bleu'.startsWithOneOf('abcdef', false) -> true
     *
     */
	public static function startsWithOneOf(s:String, chars:String, enableCaseSensitive:Bool=false):Bool {
        if (s == null || chars == null || (s.length == 0 && chars.length != 0)) return false;
        if (enableCaseSensitive) {
            var codes : Array<Int> = inline codes(chars);
            var first : Int = s.charCodeAt(0);
            for (code in codes) if (first == code) return true;
        }
        else {
            var codes : Array<Int> = inline codes(chars.toLowerCase());
            var first : Int = s.charAt(0).toLowerCase().charCodeAt(0);  // very ugly, but I don't wish to use hex tricks
            for (code in codes) if (first == code) return true;
        }
        return false;
	}

	/**
	 * @{
	 * @name To use as callback with Lambda
	 */
	@:pure public inline static function trimmed(s:String):String { return s.trim(); }
	@:pure public inline static function lower(s:String):String { return s.toLowerCase(); }
	@:pure public inline static function upper(s:String):String { return s.toUpperCase(); }
	@:pure public inline static function charcode(s:String):Int { return s.fastCodeAt(0); }
	@:pure public inline static function charAtIs(s:String, n:Int, char:String):Bool { return s.charAt(n) == char; }
	@:pure public inline static function firstCharIsUnderscore(s:String):Bool { return charAtIs(s, 0, '_'); }
	@:pure public inline static function greatest(s:String, s2:String):String { return s > s2 ? s : s2; }
	@:pure public inline static function prepend(s:String, pre:String):String { return pre + s; }
	@:pure public inline static function remove(s:String, sub:String):String { return s.replace(sub, ''); }
	@:pure public inline static function ucfirst(s:String):String { return s.substr(0,1).toUpperCase() + s.substr(1); }
	@:pure public inline static function lcfirst(s:String):String { return s.substr(0,1).toLowerCase() + s.substr(1); }
	@:pure public inline static function idem(s:String):String { return s; }
	/**
	 * @}
	 */

    /**
     * Surround a string, prepending and appending something. There are a few
     * possibilities:
     * "hi".surround("[]");                 -> "[hi]"
     * "hi".surround("BEFORE ", " AFTER");  -> "BEFORE hi AFTER"
     * "hi".surround("ab");                 -> "ahib"
     * "hi".surround("abc");                -> "abchiabc"
     *
     * @param (String s) the original string
     * @param (String prefix) Special: if it has exactly 2 characters, and
     * with2 is null, will use first char as prefix, and second one as suffix.
     * Otherwise, see example above.
     * @param (String suffix)
     */
    public static function surround(
        s:String,
        prefix:String,
        suffix:String=null
    ):String 
    {
        if (suffix == null) {
            if (prefix.length != 2) return prefix + s + prefix;
            else return prefix.charAt(0) + s + prefix.charAt(1);
        }
        else return prefix + s + suffix;
    }

    /**
     * Puts a text in bold, surrounding it with <b> and </b>
     */
    public static function boldhtml(s:String) {
        return surround(s, "<b>", "</b>");
    }

    /**
     * Center (and trim if necessary) a String so it fits into a certain visual length. 
     * Deals with ansi sequences: these make the string longer so we use
     *    StringAnsi.lengthVisible() to properly center it.
     * If too long String is shortened to the right ("long stri‥").
     * @param (String s) 
     * @param (Int w) width the string must fit/be centered into
     * @param (String paddingString) " " by default. You may use e.g. "&nbsp;".
     *                               The padding string is repeated n times 
     *                               regardless of its length.
     * @return (String)
     */
    public static function center(s:String, w:Int, paddingString:String=" ") : String {
        var len : Int = StringAnsi.lengthVisible(s);
        if (len > w) return s.substr(0, w-1) + "‥";
        var pre : Int = cast (w - len) / 2;
        var post: Int = w - len - pre;
        
        return paddingString.times(pre) + s + paddingString.times(post);
    }

    public static function sort(s1:String, s2:String) : Int {
        return s1 < s2 ? -1 : s1 > s2 ? 1 : 0;
    }

}
