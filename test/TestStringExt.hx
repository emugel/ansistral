package test;

import ansistral.StringExt;

class TestStringExt {

    public static function assert(cond:Bool, ?pos:haxe.PosInfos ) : Void 
        if (!cond) Sys.println("assertion failed at " + 
                (pos == null ? "?" :  pos.fileName + ":" + pos.lineNumber)
            );

    public static function assertEq(d1:Dynamic, d2:Dynamic, ?pos:haxe.PosInfos ) : Void 
        if (d1 != d2) Sys.println("assertion failed at " + 
                (pos == null ? "?" :  pos.fileName + ":" + pos.lineNumber) +
                ' "${Std.string(d1)}" != "${Std.string(d2)}"'
            );

    public static function main() {
        for (a in [
            // entry                charsToTrim expected
            ["  To be or not  ",    " ",        "To be or not"],
            [". tO be or not... ",  ".",        " tO be or not... "],
            ["..to Be or not..",    " ",        "..to Be or not.."],
            ["to be or not..",      " ",        "to be or not.."],
            ["to be or not..",      ".",        "to be or not"],
            ["..to be or not..",    ".",        "to be or not"],
        ]) {
            assertEq(StringExt.trimChars(a[0], a[1]), a[2]);
        }


        assertEq(StringExt.stripBase("path/to/filename.ext", "path/to/"), "filename.ext");
        assertEq(StringExt.stripBase("path/to/filename.ext", "foo.ext"), "path/to/filename.ext");
        assertEq(StringExt.stripBase("path/to/filename.ext", ""), "path/to/filename.ext");
        assertEq(StringExt.stripExt("path/to/filename.ext", ".ext"), "path/to/filename");
        assertEq(StringExt.stripExt("path/to/filename.ext", ".ext2"), "path/to/filename.ext");
        assertEq(StringExt.times(".", 3), "...");
        assertEq(StringExt.times(".", 1), ".");
        assertEq(StringExt.times(".", 0), "");
        assertEq(StringExt.times("ab", 2), "abab");
        assert(StringExt.endsWith("moon", "oon"));
        assert(!StringExt.endsWith("sun", "oon"));
        assertEq(StringExt.until("sun, moon", ","), "sun");
        assertEq(StringExt.after("sun, moon", ","), " moon");
        assertEq(StringExt.formatSignedString(-2), "-2");
        assertEq(StringExt.formatSignedString(2), "+2");
        assertEq(StringExt.formatSignedString(0), "0");
        assertEq(StringExt.formatSignedString(0, true), "");
        assertEq(StringExt.appendN("so", ".", 3), "so...");
        assertEq(StringExt.rpadSpecial("12345678", "&nbsp;", 10), "12345678&nbsp;&nbsp;");
        assertEq(StringExt.rpadSpecial("123456789", "&nbsp;", 10), "123456789&nbsp;");
        assertEq(StringExt.rpadSpecial("1234567890", "&nbsp;", 10), "1234567890");
        assertEq(StringExt.rpadSpecial("12345678901", "&nbsp;", 10), "12345678901");
        assertEq(StringExt.rpadSpecial("123456789", "&nbsp;", 10, 11), "123456789");
        assert(!StringExt.startsWithOneOf("foo", "abc"));
        assert(StringExt.startsWithOneOf("foo", "abcdef"));
        assert(!StringExt.startsWithOneOf("foo", "ABCDEF", true));
        assert(StringExt.startsWithOneOf("foo", "ABCDEF", false));
        assertEq(StringExt.lower("Building"), "Building".toLowerCase());
        assertEq(StringExt.upper("Building"), "Building".toUpperCase());
        assertEq(StringExt.charcode("B"), "B".charCodeAt(0));
        assertEq(StringExt.charcode("Bu"), "Bu".charCodeAt(0));
        assertEq(StringExt.ucfirst("lemon"), "Lemon");
        assertEq(StringExt.ucfirst("Lemon"), "Lemon");
        assertEq(StringExt.lcfirst("Lemon"), "lemon");
        assertEq(StringExt.lcfirst("lemon"), "lemon");
        assertEq(StringExt.idem("lemon"), "lemon");

        assertEq(StringExt.surround("lemon", "[]"), "[lemon]");
        assertEq(StringExt.surround("lemon", "[x]"), "[x]lemon[x]");
        assertEq(StringExt.surround("lemon", "BEFORE", "AFTER"), "BEFORElemonAFTER");
        assertEq(StringExt.surround("lemon", "ab"), "alemonb");
        assertEq(StringExt.surround("lemon", "a", "b"), "alemonb");
        assertEq(StringExt.surround("lemon", "abc"), "abclemonabc");
        assertEq(StringExt.surround("lemon", "<b>", "</b>"), "<b>lemon</b>");
        assertEq(StringExt.boldhtml("lemon"), "<b>lemon</b>");
        Sys.println("test completed");
    }


}
