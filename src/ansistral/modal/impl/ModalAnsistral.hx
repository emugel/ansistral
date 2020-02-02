package ansistral.modal.impl;

import ansistral.modal.Modal;
import tink.CoreApi;
import lambada.Duet;
import lambada.Trio;
using StringTools;
import Sys.println as pp;
using ansistral.StringExt;
using ansistral.StringAnsi;
using lambada.Lambada;

/**
 * Text console implementation for Modal using ANSI escape sequences.
 * (ANSI is used a lot for menu(), so it can scroll through a long list of items
 * and display a help at the top).
 */
class ModalAnsistral implements ansistral.modal.IModal {

    // remembering current offset for menu()
    var _offsetPerMenu : Map<String, Int>; 

    public function isInteractive() : Bool return true;
    public function new() {
        this._offsetPerMenu = new Map<String, Int>();

        // for menu()
        this._bInvertDirection = false;
        this._sSearchPatt = "";
    }

    public function promptYesNo(
        prompt : String="Are you sure? ",
        def    : DefaultChoice=None,
        ?sYes  : String="yes",
        ?sNo   : String="no",
        ?count : PromptCount=Once
    ) 
        : Future<Outcome<Bool, tink.core.Error>> 
    {
        var __p = function() {
            if (prompt.substr(-1) != " ") prompt += " ";
            if (prompt.substr(-2) != "?") prompt = prompt.substr(0, -1) + "? ";
            var i = 0;
            while (i-- < 5) {
                Sys.print(prompt + switch def {
                    case Yes: "[" + sYes.toUpperCase() + "/" + sNo  + "] ";
                    case No:  "[" + sNo .toUpperCase() + "/" + sYes + "] ";
                    case None: "[" + sYes + "/" + sNo + "] ";
                });
                var s = Sys.stdin().readLine();

                switch count {
                    case Once: 
                        switch def {
                            case Yes:  return Success(s != sNo);
                            case No:   return Success(s == sYes);
                            case None: 
                                       if      (s == sNo)  return Success(false);
                                       else if (s == sYes) return Success(true);
                                       else continue;
                        }
                    case Twice:
                        // ask confirmation if the answer is not the default one
                        // if the confirmation failed, ask again 
                        var bDef : Null<Bool> = switch def {
                            case Yes:  true;
                            case No:   false;
                            case None: null;
                        }
                        var bRes : Null<Bool> = switch def {
                            case Yes : s != sNo;
                            case No  : s == sYes;
                            case None: s == sYes ? true :( s == sNo ? false : null );
                        }
                        if (bRes == null) continue;
                        else if (bRes == bDef) return Success(bDef);
                        else {
                            Sys.print("Are you sure? [yes/NO] ");
                            if (Sys.stdin().readLine() == "yes") return Success(bRes);   // return original response
                            else {
                                if (bDef == null) {
                                    Sys.println("Failed to get a confirmation and no default value, asking again.");
                                    continue;
                                }
                                else {
                                    return Success(bDef);      // return the default (i.e. the safe)
                                }
                            }
                        }
                } // switch(count) is Once or Twice
            }
            return Failure(new tink.core.Error("5 times prompted without a correct answer"));
        };
        var outcome : Outcome<Bool, tink.core.Error> = __p();
        return Future.sync(outcome);
    }

    // blocking version
    //  e.g. if (confirm("are you sure?", No, "y", "n")).
    // @param (DefaultChoice) If None, pressing merely Enter will ask the question again until it gets answer.
    // @param (String yes)
    // @param (String no)
    // @param (PromptCount) Once or Twice? Twice is for sensitive stuffs.
    public function confirm(
        prompt : String        = "Are you sure? ",
        def    : DefaultChoice = None,
        ?sYes  : String        = "yes",
        ?sNo   : String        = "no",
        ?count : PromptCount   = Once
        ) : Bool
    {
        var __p = function() : Bool {
            if (prompt.substr(-1) != " ") prompt += " ";
            if (prompt.substr(-2) != "?") prompt = prompt.substr(0, -1) + "? ";
            while (true) {           // for this one we don't fear infinite because it's blocking
                Sys.print(prompt + switch def {
                    case Yes:  "[" + sYes.toUpperCase() + "/" + sNo  + "] ";
                    case No:   "[" + sNo .toUpperCase() + "/" + sYes + "] ";
                    case None: "[" + sYes + "/" + sNo + "] ";
                });
                var s = Sys.stdin().readLine();
                switch count {
                    case Once: 
                        switch def {
                            case Yes:  return s != sNo;
                            case No:   return s == sYes;
                            case None: 
                                       if      (s == sNo)  return false;
                                       else if (s == sYes) return true;
                                       else continue;
                        }
                    case Twice:
                        // ask confirmation if the answer is not the default one
                        // if the confirmation failed, ask again 
                        var bDef : Null<Bool> = switch def {
                            case Yes:  true;
                            case No:   false;
                            case None: null;
                        }
                        var bRes : Null<Bool> = switch def {
                            case Yes : s != sNo;
                            case No  : s == sYes;
                            case None: s == sYes ? true :( s == sNo ? false : null );
                        }
                        if (bRes == null) continue;
                        else if (bRes == bDef) return bDef;
                        else {
                            Sys.print("Are you sure? [yes/NO] ");
                            if (Sys.stdin().readLine() == "yes") return bRes;   // return original response
                            else if (bDef == null) {
                                Sys.println("Failed to get a confirmation and no default value, asking again.");
                                continue;
                            }
                            else return bDef;      // return the default (i.e. the safe)
                        }
                } // switch(count) is Once or Twice
            }
            throw "Fjf9234"; // Watchdog, theoritically impossible to reach
        };
        return __p();
    }

    public function prompt(
        prompt         : String,
        ?someDefault   : haxe.ds.Option<String>=None,
        ?maxRetries    : Int=3,
        ?placeholder   : String=null,
        ?matchingRegex : EReg=null,
        ?satisfyingCb  : String->Bool=null
    ) : Promise<String> 
        return Future.sync(input(prompt, someDefault, maxRetries, placeholder, matchingRegex, satisfyingCb));

    public function input(
        prompt         : String,
        ?someDefault   : haxe.ds.Option<String>=None,
        ?maxRetries    : Int=3,
        ?placeholder   : String=null,
        ?matchingRegex : EReg=null,
        ?satisfyingCb  : String->Bool=null
    ) : Outcome<String, Error> 
    {
        #if !sys
        #error "input() is not yet available for non sys targets"
        #end

        Sys.print(Ansi.cursor(MoveDown(999)));
        if (placeholder != null) {
            pp("-------------------------------------------------------");
            pp(placeholder);
        }
        for (nTry in 0...maxRetries) {
            Sys.print(prompt 
                    + (switch someDefault {
                        case Some(sDefault): ' ['.blue().bold() + sDefault + ']'.blue().bold();
                        case None: "";
                    })
                    + ": ");
            // --------------
            var s = Sys.stdin().readLine(); 
            // ESC+ENTER
            if (s.length == 1 && s.charCodeAt(0) == 27) return Failure(new Error("Canceled"));
            // --------------
            switch someDefault {
                case Some(sDefault): if (s == "") s = sDefault;
                case None: 
            }
            if (matchingRegex != null) {
                if (!matchingRegex.match(s)) {
                    Sys.println("error" + ": invalid entry (regex fail)");
                    continue;
                }
            }
            if (satisfyingCb != null) {
                if (!satisfyingCb(s)) {
                    Sys.println("error" + ": invalid entry (cb fail)");
                    continue;
                }
            }
            return Success(s);
        }
        return Failure(new Error("failed prompt"));
    }


    // vars for menu
    var _bInvertDirection : Bool;
    var _sSearchPatt : String;

    /**
     * A menu with actions than just "quit" and "select".
     * Until a stable version is reached, some keys are hardwired, those are
     * vim-like keys:
     *   RETURN: select
     *   q: cancel
     *   j: up
     *   k: down
     *   J: up fast
     *   K: down fast
     *   /: search down
     *   ?: search backwards
     *   n: jump to next search result
     *   N: jump to previous search result
     *   *   L: jump to bottom (low)
     *   H: jump to top (high)
     *   M: jump to middle
     *
     * @note With library slre, search will strip accents before comparing
     *
     * @param (Array<String> aAdditionalActions)
     *          E.g. ["&list", "&delete"]
     *          On TUI this will tip and accept 
     *          two new keys:
     *            1. "l" for "list" (the "&" precedes the highlight or key to use)
     *            2. "d" for "delete"
     *          If you use an already used key (e.g. "j", "k", "q") then 
     *             an exception is thrown.
     *          On a GUI it would add two more buttons ("list" and "delete",
     *          in addition to "cancel" and "select").
     *
     *      You may ["-cancel", "-select"] or one of them only,
     *        to disable default selection or cancellation. This would
     *        allow creating weird hybrids.
     *
     *      "&\t:foo" is a special value for TAB key, displayed as "TAB:foo" and
     *        recognized as the "TAB" action.
     * @param (MenuOffset) to optionally remember position between calls
     * @return (Outcome<Duet<String, Duet<String, T>>, Error>),
     *          e.g. new Duet("list", new Duet("my selected value", 5))
     *               new Duet("select", new Duet("my selected value", 5))
     */
    public function menu<T>(
        items               : Array<Duet<String, T>>,
        title               : String="Please choose an entry from this menu",
        ?aAdditionalActions : Array<String>,
        ?menuOffset         : MenuOffset=None,
        ?fItemOption        : T->Array<MenuItemOption>=null
    ) : Outcome<Duet<String, Duet<String, T>>, Error> {
        var items = items.map( duet -> new Trio(
            duet.a,
            duet.b,
            fItemOption == null
            ? []
            : fItemOption(duet.b)
        ));
        if (aAdditionalActions == null) aAdditionalActions = [];
        var disableSelect = aAdditionalActions.has("-select");
        var disableCancel = aAdditionalActions.has("-cancel");
        var keyHavingTabOrNull : Null<String> = aAdditionalActions.find( s -> s.startsWith("&\t"));
        aAdditionalActions.remove("-select");
        aAdditionalActions.remove("-cancel");
        if (keyHavingTabOrNull != null)
            aAdditionalActions.remove(keyHavingTabOrNull);

        function _findHintCode(s:String) : Int { // {{{3 "go&to" 
            // It can not fail.
            // The Failure is checked right below.
            // @param (String s) Something like "&list", "e&xpand", "naked", "&c&r&a&z&y".
            //      "&list"      -> "l"
            //      "e&xpand"    -> "x"
            //      "naked"      -> "n"
            //      "&c&r&a&z&y" -> "c" (only first "&" is considered)
            var i = s.indexOf("&");
            return s.charCodeAt( i == -1 ? 0 : i + 1 );
        }
        var hintCodes = aAdditionalActions
                            .filter( s -> s != null && s.length >= 1 )
                            .map( s -> _findHintCode(s)) 
        ;
        for (key in hintCodes) {
            switch key {
                case "j".code | "k".code | "J".code | "K".code | "M".code | "L".code | "H".code | "/".code | "n".code | "N".code | "?".code: 
                    return Failure(new Error("Can not use hints j,k,J,L,H,K,M,n,N,/,? in menus: " 
                            + key + " in " + aAdditionalActions.join(", ")
                    ));
                case "q".code if (!disableCancel):
                    return Failure(new Error("Can not use hint q in menu if '-cancel' was not specified: " 
                            + key + " in " + aAdditionalActions.join(", ")
                    ));
                case _:
            }
        }  // }}}3

        var dblBuf = new Array<String>();
        var headerH = 0;            // header height in dblBuf

        /**
         * Search in menu, circular, back or forth.
         * @param (String sSearchPatt) a mere text search for now
         * @param (Bool bInvertDirec) true to search backwards
         * @param (Int nCur) current menuitem index (cur)
         * @return (Int) new index. Same as nCur if unfound.
         */
        function _searchInMenu(sSearchPatt, bInvertDirec, nCur) : Int {  // return index in dblBuf
            // we don't want to work on dblBuf because it contains header
            var a = dblBuf.slice(headerH); 
            nCur += headerH;
            // using ringModulo() array `a` can be worked upon as if infinite ring
            var stopAt = nCur + (bInvertDirec ? -1 : 1) * a.length;

            /**
             * Whether s2 matches s1.
             * if -lib slre, strip accent before comparing
             * @param (s1) The candidate
             * @param (s2) The (text) pattern
             *                        if `s2` contains no chars in `[A-Z]`, 
             *                        search is case-insensitive
             */
            function _match(s1, s2) : Bool {
                #if slre
                s1 = grepsuzette.slre.Tools.stripAccents(s1);
                s2 = grepsuzette.slre.Tools.stripAccents(s2);
                #end
                if (! ~/[A-Z]/.match(s2)) {
                    s1 = s1.toLowerCase();
                    s2 = s2.toLowerCase();
                }
                return s1.indexOf(s2) >= 0;
            }

            while ( bInvertDirec ? --nCur > stopAt : ++nCur < stopAt) {
                if (_match( a[ringModulo(nCur - headerH, a.length)], sSearchPatt )) {
                    return ringModulo(nCur - headerH, a.length);
                }
                // #if (!slre)
                // if (.toLowerCase().indexOf(sSearchPatt).toLowerCase() >= 0) {
                //     return ringModulo(nCur - headerH, a.length);
                // }
                // #else
                // // strip accents if lib slre is used
                // if ((grepsuzette.slre.Tools.stripAccents(
                //         a[ringModulo(nCur - headerH, a.length)]
                //     ).toLowerCase().indexOf( 
                //         grepsuzette.slre.Tools.stripAccents(sSearchPatt).toLowerCase()
                //     ) >= 0
                // )) {
                //     return ringModulo(nCur - headerH, a.length);
                // }
                // #end
            }
            return ringModulo(nCur - headerH, a.length);   // actually equals to original nCur
        }
        /**
         * Redraw function.
         */
        function _redraw(indexCurrentLine:Int=0, screenW:Int, screenH:Int) {
            // redraw all menu, e.g. when j/k are pressed,
            //   or when screenW or screenH changes

            dblBuf = [];
            dblBuf.push(
                Ansi.clearScreen() + 
                // Ansi.cursor(RestorePos) +
                title
            );

            dblBuf.push("Keys: " +      // {{{3 keys help
                [ new Duet("down"    , "j"),
                  new Duet("up"      , "k"),
                  new Duet("search"  , "/"),
                  new Duet("next"    , "n"),
                ]
                .concat( disableSelect ? [] : [new Duet("select", "ENTER")] )
                .concat( disableCancel ? [] : [new Duet("cancel", "q")] )
                .concat( keyHavingTabOrNull == null ? [] : [new Duet(keyHavingTabOrNull.after(":"), "TAB")] )
                .concat(
                    aAdditionalActions
                        .filter( s -> s != null && s.length >= 1 )
                        .map(    s -> new Duet(s, String.fromCharCode(_findHintCode(s))) )
                ).map( function (duet) {
                    var i = duet.a.indexOf(duet.b);
                    if (i == -1) return duet.b.cyan().bold() + ":".bold() + duet.a;
                    else {
                        return (i > 0 ? duet.a.substr(0, i-1) : "")
                            +  duet.a.substr(i, 1).cyan().bold()
                            +  duet.a.substr(i+1)     
                        ;
                    }
                })
                 .join(" ".faint())
            );
            dblBuf.push("-------------------------------------------------------"); // }}}3
            headerH = dblBuf.length;

            if (items.length == 0) {        // {{{3 dblBuf populating (content)
                dblBuf.push("(It's empty...)"); 
            }
            else {
                var i = 0;
                for (trio in items) {
                    if (trio.c.has(GrayedOut)) {
                        if (i++ == indexCurrentLine) 
                            disableSelect 
                                ? dblBuf.push(("> " + trio.a))
                                : dblBuf.push(("> " + trio.a).negative());
                        else 
                            dblBuf.push("  " + trio.a.faint());
                    }
                    else if (trio.a.indexOf("/") >= 0) {
                        if (i++ == indexCurrentLine) 
                            disableSelect 
                                ? dblBuf.push(("> " + trio.a))
                                : dblBuf.push(("> " + trio.a).negative());
                        else 
                            dblBuf.push("  " + trio.a.untilLast("/").faint() + "/".yellow() + trio.a.afterLast("/"));
                    }
                    else {
                        if (i++ == indexCurrentLine) 
                            disableSelect
                                ? dblBuf.push(("> " + trio.a))
                                : dblBuf.push(("> " + trio.a).negative());
                        else 
                            dblBuf.push("  " + trio.a);
                    }
                }
            }
            // now dblBuf ::=> pp()
            // first N lines are headerH
            // the rest depends on indexCurrentLine, screenH, and dblBuf.length
            // cccccc  
            // cccccc
            // ...ccc  screenH = 4 - 2 (header taking 2)
            // ...ccc  dblBuf.length = 15
            // cccccc  indexCurrentLine = 7
            //         we want indexCurrentLine towards the middle  // }}}3
            screenH -= 1;           // because pp() will produce empty line @ the bottom
            for (i in 0...headerH) 
                pp(dblBuf[i]);
            var startY = indexCurrentLine - Std.int(screenH / 2);
            if (startY < 0) startY = 0;
            var endY = startY + screenH - headerH;
            endY = cast Math.min(endY, items.length);
            if (endY - startY < screenH - headerH) startY = endY + headerH - screenH;
            if (startY < 0) startY = 0; // again...
            for (i in startY ... endY) {
                pp(dblBuf[i + headerH]);
            }

            // Sys.print(Ansi.cursor(MoveUp(items.length - indexCurrentLine )));
        } // internal function _redraw()

        var char = "_".code;
        var screen = ansistral.Screen.detectSize();
        var cur = switch menuOffset { // restore from menuOffsetId
            case null | None: 0;
            case OffsetId(menuOffsetId):
                var savedOffset : Null<Int> = _offsetPerMenu[menuOffsetId];
                if (savedOffset == null) 0 else savedOffset;
        };

        while (true) {
            _redraw( 
                cur,
                screen.width,
                screen.height
            );
            switch Sys.getChar(false) {
                case "j".code /*| 116*/: cur++;
                case "k".code /*| 111*/: cur--;
                case "L".code: cur = items.length - 1;
                case "H".code: cur = 0;
                case "K".code: cur -= 5;
                case "J".code: cur += 5;
                case "M".code: cur = Std.int( items.length / 2 );
                case "/".code: switch input("Search", Some(_sSearchPatt), 1) { case Success(s): cur = _searchInMenu(_sSearchPatt = s, _bInvertDirection = false, cur); case _: }
                case "?".code: switch input("Search backwards", Some(_sSearchPatt), 1) { case Success(s): cur = _searchInMenu(_sSearchPatt = s, _bInvertDirection = true, cur); case _: }
                case "n".code: cur = _searchInMenu(_sSearchPatt, _bInvertDirection, cur);
                case "N".code: cur = _searchInMenu(_sSearchPatt, !_bInvertDirection, cur);
                case 9 if (keyHavingTabOrNull != null): return Success( new Duet( "TAB", items[cur].ab() ));
                case 13 | 10 if (!disableSelect): return Success( new Duet("select", items[cur].ab() ));
                // it would take some time to also
                // have arrows work.
                // Because here at least they are
                // prefixed with an "ESC" (0x1b) followed
                // by e.g. for left: 91 and 68.
                // So. no ESC no arrows for now.
                case "q".code if (!disableCancel): 
                    Sys.print(Ansi.clearScreen());
                    return Success(new Duet("cancel", null));
                case xxx: 
                    // custom actions if there is one match (e.g. "l" pressed for "&list")
                    for (code in hintCodes) 
                        if (code == xxx) 
                            return Success(
                                new Duet(
                                    String.fromCharCode(code),
                                    (cur < items.length) ? items[cur].ab() : null
                                )
                            );
            }
            if (cur < 0) cur = 0;
            if (cur > items.length - 1) cur = items.length - 1;
            switch menuOffset { // save menu offset
                case OffsetId(menuOffsetId): _offsetPerMenu.set(menuOffsetId, cur);
                case null | None:
            }
        }
        return Failure(new Error("Watchdog FKw48 should never happen"));
    }

    /**
     * ringMod(). A "ring" modulo.
     * Why? -3 % 7 gives -3. 
     * This is bad news when working with array length,
     * we need an operation that would give us 7 - 3 = 4,
     * to access arr[ringModulo(i)], that way array works like
     * a ring.
     */
    public static function ringModulo(i:Int, len:Int) : Int {
        var at = i % len;
        return at >= 0
            ? at
            : len + at
        ;
    }
}
// vim: fdm=marker
