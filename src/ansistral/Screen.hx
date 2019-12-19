package ansistral;

/**
 * Term size detection for different sys targets (and OS).
 * This is very incomplete feel free to contribute.
 */
class Screen {

    /**
     * Detect term size, or throw if unable to.
     */
    @throw public static function detectSize() : { width:Int, height:Int } {
        var width : Int = 0;
        var height: Int = 0;
        #if sys
        function stdoutFromShellCmd(cmdline:String) : String {
            var p = new sys.io.Process(cmdline);
            var s = p.stdout.readLine();
            while (p.exitCode() == null) Sys.sleep(0.015);
            p.close();
            return s;
        }
        switch Sys.systemName() {
            case "Windows":
                // powershell is available since all windows since windows 7 (2009)
                // WindowSize            : 144,49
                // https://superuser.com/questions/680746/is-it-possible-to-fetch-the-current-cmd-window-size-rows-and-columns-in-window
                var s = stdoutFromShellCmd(
                    "powershell -command '&{$H=get-host;$H.ui.rawui.WindowSize;}'"
                );
                var ereg = ~/([0-9]+),([0-9]+)/;
                if (ereg.match(s)) {
                    width = cast Std.parseInt(ereg.matched(1));
                    height = cast Std.parseInt(ereg.matched(2));
                }
            case "Linux" | "BSD" | "Mac":
                var i = Std.parseInt(stdoutFromShellCmd("tput cols"));
                width = i == null ? 80 : cast (i, Int);
                var i = Std.parseInt(stdoutFromShellCmd("tput lines"));
                height = i == null ? 25: cast (i, Int);
            default: 
                throw("Unrecog OS");
        }
        #else
        throw "ansistral.Screen.detectSize() only supported on sys platforms";
        #end
        return {width:width, height:height};
    }
    

}
