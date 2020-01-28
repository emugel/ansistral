package ansistral.modal;

import lambada.Duet;
import tink.CoreApi;
import ansistral.modal.Modal;

/**
 * Interface for TextUI or graphical ui to implement.
 * On non-interactive implementation, it will always fail with I_am_a_Teapot.
 */
interface IModal {

    /**
     * Whether there is actually a user interaction.
     * This can be used like `Modal.getInstance().isInteractive()`,
     */
    public function isInteractive() : Bool;

    /**
     * Asynchronous prompt for `yes` or `no`.
     * Default answer of `None` shall reprompt up to 3 times
     * until answer obtained, after which it triggers a Failure.
     * @param (String prompt) A String like " [NO/yes]: " 
     *                        Twill be auto-appended to this prompt.
     *                        (note FULLCAPS shows the DefaultChoice).
     * @param (DefaultChoice def=None) 
     * @param (String sYes/sNo)        Labels/text to use for yes and no.
     * @return (Promise<Bool>) 
     */
    public function promptYesNo(
        prompt            : String                         = "Are you sure? ",
        def               : DefaultChoice                  = None,
        ?sYes             : String                         = "yes",
        ?sNo              : String                         = "no",
        ?count            : PromptCount                    = Once
    ) : Promise<Bool>;

    /**
     * Sync (blocking) version of promptYesNo.
     * confirm() is designed to be very simple, returning a mere Bool:
     * You either get confirmation or you don't.
     * Non-interactive implementation always return false here.
     * So if you want true instead you need to use:
     * @example
     * var gui = Modal.getInstance();
     * if (!gui.isInteractive() || gui.confirm()) {
     *    // confirmed or non-interactive
     * }
     * @endexample
     */
    public function confirm(
        prompt            : String                         = "Are you sure? ",
        def               : DefaultChoice                  = None,
        ?sYes             : String                         = "yes",
        ?sNo              : String                         = "no",
        ?count            : PromptCount                    = Once
    ) : Bool;

    /**
     * Async String prompt. 
     * It may be cancelled by entering Esc or by some other mean depending on
     * the implementation, therefore it's a Promise.
     * @param (String prompt) The prompt to show.
     * @param (Option<String>) `None` does not provide default value. 
     *                         `Some("foo")` to append " [foo] " in the prompt,
     *                         using "foo" if RETURN is directly pressed.
     * @param (maxRetries) return a Failure after this number of tries, i.e. if
     *                     failing `matchingRegex` or `satisfyingCb`.
     * @param (placeholder) some longer help (if in a TUI would be shown before)
     * @param (EReg) when not null, a prompt will be attempted again if the regex didn't match.
     * @param (String->Bool) when not null, a prompt will be attempted again if the cb returned false.
     * @return (Promise<String>)
     */
    public function prompt(
        prompt         : String,
        ?someDefault   : haxe.ds.Option<String>=None,
        ?maxRetries    : Int=3,
        ?placeholder   : String=null,
        ?matchingRegex : EReg=null,
        ?satisfyingCb  : String->Bool=null
    ) : Promise<String>;

    /**
     * Synchronous prompt(). input() can be cancelled but is blocking.
     * @param (String prompt) The prompt to show.
     * @param (Option<String>) `None` does not provide default value. 
     *                         `Some("foo")` to append " [foo] " in the prompt,
     *                         using "foo" if RETURN is directly pressed.
     * @param (maxRetries) return a Failure after this number of tries, i.e. if
     *                     failing `matchingRegex` or `satisfyingCb`.
     * @param (placeholder) some longer help (if in a TUI would be shown before)
     * @param (EReg) when not null, a prompt will be attempted again if the regex didn't match.
     * @param (String->Bool) when not null, a prompt will be attempted again if the cb returned false.
     * @return (Outcome<String, Error>)
     *          e.g. Failure(new Error(I_am_a_Teapot, "non-interactive"))
     */
    public function input(
        prompt         : String,
        ?someDefault   : haxe.ds.Option<String>=None,
        ?maxRetries    : Int=3,
        ?placeholder   : String=null,
        ?matchingRegex : EReg=null,
        ?satisfyingCb  : String->Bool=null
    ) : Outcome<String, Error>;

    /**
     * A sync menu with actions (in addition to the default "quit" and "select").
     * TODO maybe async.
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
     * @param (pos) If not null, position will be used as identifier to recall
     *              offset of the cursor next time the menu would be called
     *              from the same exact location
     * @return (Outcome<Duet<String, Duet<String, T>>, Error>),
     *          e.g. 
     *               Success new Duet("select", new Duet("my selected value", 5))
     *               Success new Duet("cancel", null)
     *               Success new Duet("list", new Duet("my selected value", 5)) <- a custom action
     *               Failure(new Error(I_am_a_Teapot, "non-interactive"))
     */
    public function menu<T>(
        items       : Array<Duet<String, T>>,
        title       : String="Please choose an entry from this menu",
        ?aAdditionalActions:Array<String>,
        ?menuOffset : MenuOffset=null,
        ?fItemOption: T->Array<MenuItemOption>=null
    ) : Outcome<Duet<String, Duet<String, T>>, Error>;

}
