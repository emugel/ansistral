package grepsuzette.ansi;

/**
 *
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:enum
abstract AnsiColor(Int) {
    var BLACK = 0;
    var RED = 1;
    var GREEN = 2;
    var YELLOW = 3;
    var BLUE = 4;
    var MAGENTA = 5;
    var CYAN = 6;
    var WHITE = 7;
    var DEFAULT = 9;
}
