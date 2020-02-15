package test;

import ansistral.modal.Modal;
import lambada.Duet;
import tink.CoreApi;
using Std;

// - nonInteractive is an implementation where unattended execution takes place (no UI)
// - tui stands for "text ui"
// TODO would be nice if using stdin we could have this test auto-test...
class TestModal extends haxe.unit.TestCase {

    public function assert(cond:Bool, ?pos:haxe.PosInfos ) assertTrue(cond, pos);
    public function assertEq(a:Dynamic, b:Dynamic, ?pos:haxe.PosInfos ) assertEquals(a, b, pos);
    public function here( ?pos:haxe.PosInfos ) : haxe.PosInfos return pos;

    // non-interactive impl ----------------
    // ASYNC            SYNC
    // ------------------------------------
    // promptYesNo()    confirm()
    // prompt()         input()
    //                  menu()
    //
    public function test_noninteractive() {
        Modal.setInstance(new ansistral.modal.impl.ModalNonInteractive());
        var nonInteractive = Modal.getInstance();
        assert( ! nonInteractive.isInteractive() );        

        var completed = false; // {{{2
        function assert_teapot<T>(out:Outcome<T, Error>, ?pos:haxe.PosInfos ) {
            switch out {
                case Success(_): assert( false, pos );
                case Failure(e): assertEquals( e.code, I_am_a_Teapot, pos );
            }
            completed = true;
        } // }}}2

        // sync, Failure with Error I_am_a_Teapot: input() menu() 
        assert_teapot( nonInteractive.input("some prompt") );
        assert_teapot( nonInteractive.menu([], "some title") );

        // sync, merely false: confirm()
        assert( ! nonInteractive.confirm("Whatever") );    

        // ---------------------------------------------
        // async: promptYesNo()
        completed = false;
        nonInteractive.promptYesNo().handle(assert_teapot.bind(_, here() ));
        while (!completed) Sys.sleep(0.1);        

        // async: prompt()
        completed = false;
        nonInteractive.prompt("some prompt").handle(assert_teapot.bind(_, here() ));
        while (!completed) Sys.sleep(0.1);        

    }

    // ---------- text ui -------------------------
    // ASYNC            SYNC
    // ------------------------------------
    // promptYesNo()    confirm()
    // prompt()         input()
    //                  menu()
    //
    public function test_tui_promptYesNo() : Void {
        Modal.enableInteractiveTUI();
        var tui = Modal.getInstance();

        // ...use trick to get blocking futures...
        var completed = false;
        tui.promptYesNo("Press ENTER for Yes please (or test will fail)", Yes )
           .handle( function(out:Outcome<Bool, Error>) {
                switch out {
                    case Success(b): assert( b );
                    case Failure(e): trace("Fail with " + e.string());
                                     assert( false );
                }
                completed = true;
            })
        ; while (!completed) Sys.sleep(0.1);        

        // ...use trick to get blocking futures...
        var completed = false;
        tui.promptYesNo("Sensitive test where default is accepted, with confirmation of `Twice`. Hit ENTER to accept default of `yes`, then no confirmation should be asked", Yes, Twice )
           .handle( function(out:Outcome<Bool, Error>) {
                switch out {
                    case Success(b): assert( b );
                    case Failure(e): trace("Fail with " + e.string());
                                     assert( false );
                }
                completed = true;
            })
        ; while (!completed) Sys.sleep(0.1);        

        // ...use trick to get blocking futures...
        var completed = false;
        tui.promptYesNo("Sensitive test where default is declined, with confirmation of `Twice`. Type `no` first, then `yes`  (or test shall fail)", Yes, Twice )
           .handle( function(out:Outcome<Bool, Error>) {
                switch out {
                    case Success(b): assert( ! b );
                    case Failure(e): trace("Fail with " + e.string());
                                     assert( false );
                }
                completed = true;
            })
        ; while (!completed) Sys.sleep(0.1);        
    }

    public function test_tui_prompt() : Void {
        Modal.enableInteractiveTUI();
        var tui = Modal.getInstance();

        // ...use trick to get blocking futures...
        var completed = false;
        tui.prompt("What is your name", Some("john") )
           .handle( function(out:Outcome<String, Error>) {
                switch out {
                    case Success(s): assert( true );
                    case Failure(e): trace("Fail with " + e.string());
                                     assert( false );
                }
                completed = true;
            })
        ; while (!completed) Sys.sleep(0.1);

        // ...use trick to get blocking futures...
        var completed = false;
        tui.prompt(
            "what is your age? (7 >= age >= 77)", 
            "Placeholder: Must enter a age, check w/ a callback", 
            function (sAge) { 
                var age = sAge.parseInt(); 
                return age != null 
                  &&  age >= 7 
                  &&  age <= 77 ;
        })
       .handle( function(out:Outcome<String, Error>) {
            switch out {
                case Success(s): assert( true );
                case Failure(e): trace("Fail with " + e.string());
                                 assert( false );
            }
            completed = true;
        });
        while (!completed) Sys.sleep(0.1);        

        // ...use trick to get blocking futures...
        var completed = false;
        tui.prompt(
            "what is your favourite color", 
            "Placeholder: Regex check /red|blue|yellow|blue|orange|green|white|black/",
            ~/^red|blue|yellow|blue|orange|green|white|black$/i
        ) .handle( function(out:Outcome<String, Error>) {
            switch out {
                case Success(_): assert( true );
                case Failure(e): trace("Fail with " + e.string());
                                 assert( false );
            }
            completed = true;
        });
        while (!completed) Sys.sleep(0.1);
    }

    function test_tui_confirm() {
        Modal.enableInteractiveTUI();
        var tui = Modal.getInstance();
        assert( tui.isInteractive() );
        assert( tui.confirm("Press ENTER for Yes please (or test will fail)", Yes ));
        assert( tui.confirm("Enter 'yes' manually please (or test will fail)", None ));
    }

    function test_tui_input() {
        Modal.enableInteractiveTUI();
        var tui = Modal.getInstance();

        function assert_success( out:Outcome<String, Error>, ?pos:haxe.PosInfos ) { switch out {
            case Success(s): assert( true );
            case Failure(e): trace("Fail with " + e.string()); assert( false );
        }}

        assert_success( tui.input("[sync] your name", Some("Chen") ) );

        assert_success( tui.input(
            "what is your age? (7 >= age >= 77)", 
            "Placeholder: Must enter a age, check w/ a callback", 
            function (sAge) { 
                var age = sAge.parseInt(); 
                return age != null 
                  &&  age >= 7 
                  &&  age <= 77 ;
        }) );

        assert_success( tui.input(
            "what is your favourite color", 
            "Placeholder: Regex check /red|blue|yellow|blue|orange|green|white|black/",
            ~/^red|blue|yellow|blue|orange|green|white|black$/i
        ) );
    }

    function test_tui_menu() {
        Modal.enableInteractiveTUI();
        var tui = Modal.getInstance();
        var a = [ "mon", "tues", "wednes", "thurs", "fri", "sat", "sun" ];
        switch tui.menu(
            a.map(s -> new Duet( s + "day", s )),
            "what's the longest day name? (thursday is grayed out)",
            [],
            null,
            s -> (s.length + 3 == "wednesday".length ? [GrayedOut] : [])  // grayout days of 9 letters
        ) {
            case Success(duet_action_duetStringT):
                switch duet_action_duetStringT.a {
                    case "select": 
                        assertEq( duet_action_duetStringT.b.a, "wednesday" );
                        assertEq( duet_action_duetStringT.b.b, "wednesday".length );
                    case "cancel": 
                        trace(" You should not cancel! ");
                        assert( false );
                    case _:
                        trace("This should never have happened 43852435");
                        assert( false );
                }
            case Failure(err): assert( false );
        }

    }

}
// vim: fdm=marker
