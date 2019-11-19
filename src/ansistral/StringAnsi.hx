package ansistral;

import ansistral.Ansi;
import ansistral.AnsiTextAttribute;

/**
 * Just extend with "using".
 * Eg. "Text to put in ansi bolc".bold()
 */
class StringAnsi {
    public static inline function bold(s:String):String return Ansi.attr(INTENSITY_BOLD) + s + Ansi.attr(INTENSITY_OFF); 
    public static inline function italic(s:String):String return Ansi.attr(ITALIC) + s + Ansi.attr(ITALIC_OFF); 
    public static inline function underline(s:String):String return Ansi.attr(UNDERLINE_SINGLE) + s + Ansi.attr(UNDERLINE_OFF); 
    public static inline function blink(s:String):String return Ansi.attr(BLINK_SLOW) + s + Ansi.attr(BLINK_OFF); 
    public static inline function negative(s:String):String return Ansi.attr(NEGATIVE) + s + Ansi.attr(NEGATIVE_OFF); 
    public static inline function faint(s:String) : String return Ansi.attr(INTENSITY_FAINT) + s + Ansi.attr(INTENSITY_OFF); 

    public static inline function black   ( s:String):String return Ansi.fg ( BLACK) + s + Ansi.fg     ( DEFAULT);
    public static inline function red     ( s:String):String return Ansi.fg ( RED) + s + Ansi.fg       ( DEFAULT);
    public static inline function green   ( s:String):String return Ansi.fg ( GREEN) + s + Ansi.fg     ( DEFAULT);
    public static inline function yellow  ( s:String):String return Ansi.fg ( YELLOW) + s + Ansi.fg    ( DEFAULT);
    public static inline function blue    ( s:String):String return Ansi.fg ( BLUE) + s + Ansi.fg      ( DEFAULT);
    public static inline function magenta ( s:String):String return Ansi.fg ( MAGENTA) + s + Ansi.fg   ( DEFAULT);
    public static inline function cyan    ( s:String):String return Ansi.fg ( CYAN) + s + Ansi.fg      ( DEFAULT);
    public static inline function white   ( s:String):String return Ansi.fg ( WHITE) + s + Ansi.fg     ( DEFAULT);

    public static inline function bgBlack   ( s:String):String return Ansi.bg ( BLACK) + s + Ansi.bg     ( DEFAULT);
    public static inline function bgRed     ( s:String):String return Ansi.bg ( RED) + s + Ansi.bg       ( DEFAULT);
    public static inline function bgGreen   ( s:String):String return Ansi.bg ( GREEN) + s + Ansi.bg     ( DEFAULT);
    public static inline function bgYellow  ( s:String):String return Ansi.bg ( YELLOW) + s + Ansi.bg    ( DEFAULT);
    public static inline function bgBlue    ( s:String):String return Ansi.bg ( BLUE) + s + Ansi.bg      ( DEFAULT);
    public static inline function bgMagenta ( s:String):String return Ansi.bg ( MAGENTA) + s + Ansi.bg   ( DEFAULT);
    public static inline function bgCyan    ( s:String):String return Ansi.bg ( CYAN) + s + Ansi.bg      ( DEFAULT);
    public static inline function bgWhite   ( s:String):String return Ansi.bg ( WHITE) + s + Ansi.bg     ( DEFAULT);

    public inline static function bg(s:String, color:AnsiColor) : String {
        return Ansi.bg(color);
    }
    
    /**
     * Clear screen.
     * You need to e.g. pp << cls()
     */
    public inline static function cls() : String return Ansi.clearScreen();
    public inline static function cll() : String return clearLine();
                                          
    public static inline function clearLine() : String return Ansi.clearLine();
    
    public static function goToHome() : String 
        return Ansi.cursor(GoToHome);

    /**
     * @return (String) stripped from all its ansi characters.
     * @sa lengthVisible()
     */
    public static function stripAnsi(s:String) : String {
        return ~/\x1B\[[^a-zA-Z]*[a-zA-Z]/g.replace(s, "");
        // return s.replace(hx.strings.ansi.Ansi.ESC, ""
    }

    /**
     * Count utf-8 characters without counting control characters.
     * For instance "I am [37mvery[0m honored".lengthVisible() == "I am very
     * honored".length.
     *
     * This is equivalent to stripAnsi() but about 5-10 times faster.
     */
    public static function lengthVisible(s:String):Int {
        var inEscape = 0;
        var chars    = 0;
        for (i in 0...s.length) {
            // trace('i:$i chars:$chars CHAR:${s.charAt(i)} inEscape:$inEscape');
            if (inEscape == 0) {
                // [ 01
                if (s.charCodeAt(i) == "".code) { inEscape = 1; }
                else { chars++; }
            }
            else if (inEscape == 1) {
                // [ 01
                if (s.charCodeAt(i) == "[".code) { inEscape = 2; }
                else { inEscape = 0; chars += 2; }
            }
            else {
                var code : Int = s.charCodeAt(i) | 0x20;
                if (code >= "a".code && code <= "z".code) { inEscape = 0; }
            }
        }
        return chars;
    }
}
