package ansistral;

/**
 *
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
enum AnsiCursor {

    GoToHome;
    GoToPos(line:Int, column:Int);
    MoveUp(lines:Int);
    MoveDown(lines:Int);
    MoveRight(columns:Int);
    MoveLeft(columns:Int);
    SavePos;
    RestorePos;
}


