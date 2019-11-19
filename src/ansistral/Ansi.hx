package ansistral;

import ansistral.AnsiColor;
import ansistral.AnsiTextAttribute;

/**
 * https://en.wikipedia.org/wiki/ANSI_escape_code
 * http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/c327.html
 * http://ascii-table.com/ansi-escape-sequences.php
 *
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class Ansi {

    /**
     * ANSI escape sequence header
     */
    public static inline var ESC = "\x1B[";

    /**
     * sets the given text attribute
     */
    inline
    public static function attr(attr:AnsiTextAttribute):String {

        return ESC + (attr) + "m";
    }

    /**
     * set the text background color
     *
     * <pre><code>
     * >>> Ansi.bg(RED) == "\x1B[41m"
     * </code></pre>
     */
    inline
    public static function bg(color:AnsiColor):String {
        return ESC + "4" + color + "m";
    }

    /**
     * <pre><code>
     * >>> Ansi.cursor(MoveUp(5)) == "\x1B[5A"
     * >>> Ansi.cursor(GoToPos(5,5)) == "\x1B[5;5H"
     * </code></pre>
     */
    public static function cursor(cmd:AnsiCursor):String {
        return switch(cmd) {
            case GoToHome: Ansi.ESC + "H";
            case GoToPos(line, column): Ansi.ESC + line + ";" + column + "H";
            case MoveUp(lines): Ansi.ESC + lines + "A";
            case MoveDown(lines): Ansi.ESC + lines + "B";
            case MoveRight(columns): Ansi.ESC + columns + "C";
            case MoveLeft(columns): Ansi.ESC + columns + "D";
            case SavePos: Ansi.ESC + "s";
            case RestorePos: Ansi.ESC + "s";
        }
    }

    /**
     * Clears the screen and moves the cursor to the home position
     */
    inline
    public static function clearScreen():String {
        return ESC + "2J";
    }

    /**
     * Clear all characters from current position to the end of the line including the character at the current position
     */
    inline
    public static function clearLine():String {
        return ESC + "K";
    }

    /**
     * set the text foreground color
     *
     * <pre><code>
     * >>> Ansi.fg(RED) == "\x1B[31m"
     * </code></pre>
     */
    inline
    public static function fg(color:AnsiColor):String {
        return ESC + "3" + color + "m";
    }

}

