package ansistral.modal.impl; 

import ansistral.modal.Modal;
import lambada.Duet;
import tink.CoreApi;

/**
 * Why a non-interactive implementation (non-interactive interface?!)?
 * Because some procedures may or may not have UI. For instance,
 * running something interactively you may want to ask confirmation 
 * with `confirm()`, but use a special value of `true` or `false` when 
 * and only when the same code is run non-interactively. This way, you
 * need only one function.
 * 
 * ModalNonInteractive will simply Fail for all implemented methods, 
 * with a `Failure(new Error(I_am_a_Teapot, "non-interactive")`.
 *
 * The only method that differs is confirm(), because it returns a Bool and
 * for UI non-interactive this means no confirmation, so `false`.
 *
 * ```haxe
 * var gui = Modal.getInstance();
 * if (!gui.isInteractive() || gui.confirm()) {
 *    // confirmed or non-interactive
 * }
 * ```
 * 
 * Here are some examples of how you would have a default value
 * for non-interactive, while also have the code work if 
 * implementation uses a UI:
 *
 * @example {{{2
 * // Example 1: Mapping a default value of No when non-interactive:
 * var gui = Modal.getInstance();
 * gui.promptYesNo("Are you sure", Yes)
 *    .map(o -> return switch o {
 *       case Success(_): o;
 *       case Failure(e): if (e.code == I_am_a_Teapot) Success(No) else o;
 *    })
 *    .handle( function(o)
 *      switch o {
 *          case Success(bool):
 *              // here, if non-interactive, value is going to be false.
 *              // otherwise, it will be the answer from user (true if he 
 *              //   accepted default answer).
 *          case Failure(xxx):
 *              // here would be indicative of another problem,
 *              // e.g. maybe user declined to answer.
 *      }
 *    );
 *
 * // Example 2: Checking beforehand if Modal is non-interactive
 * var gui = Modal.getInstance();
 * (gui.isInteractive()
 *    ? gui.promptYesNo("Are you sure", Yes)
 *    : Promise.lift(Success(No))
 * ).handle( function(outcome) 
 *      switch o {
 *          case Success(bool):
 *              // here, if non-interactive, value is going to be false.
 *              // otherwise, it will be the answer from user (true if he 
 *              //   accepted default answer).
 *          case Failure(xxx):
 *              // here would be indicative of another problem,
 *              // e.g. maybe user declined to answer.
 * );
 *
 * // Example 3: Checking upon Failure whether Error code was I_am_a_Teapot.
 * var gui = Modal.getInstance();
 * gui.promptYesNo("Are you sure", Yes)
 *    .handle( function(outcome) 
 *      switch o {
 *          case Success(bool):
 *              // user entered answer
 *          case Failure(xxx):
 *              if (xxx.code == I_am_a_Teapot) {
 *                  // non-interactive
 *              }
 *              else {
 *                  // here would be indicative of another problem,
 *                  // e.g. user declined to answer.
 *              }
 *      }
 * );
 * @endexample }}}2
 *
 */
class ModalNonInteractive implements ansistral.modal.IModal {

    public function new() {}
    public function isInteractive() : Bool return false;

    static inline var msg = "non-interactive";

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
        ?count            : PromptCount                    = null       // Once
    ) : Bool 
        return false;

    public function promptYesNo(
        prompt            : String                         = "Are you sure? ",
        def               : DefaultChoice                  = None,
        ?sYes             : String                         = "yes",
        ?sNo              : String                         = "no",
        ?count            : PromptCount                    = Once
    ) : Future<Outcome<Bool, tink.core.Error>> 
        return Future.sync(Failure(new Error(I_am_a_Teapot, msg)));
    
    public function prompt(
        prompt         : String,
        ?someDefault   : haxe.ds.Option<String>=None,
        ?maxRetries    : Int=3,
        ?placeholder   : String=null,
        ?matchingRegex : EReg=null,
        ?satisfyingCb  : String->Bool=null
    ) : Promise<String> 
        return Future.sync(Failure(new Error(I_am_a_Teapot, msg)));

    public function input(
        prompt         : String,
        ?someDefault   : haxe.ds.Option<String>=None,
        ?maxRetries    : Int=3,
        ?placeholder   : String=null,
        ?matchingRegex : EReg=null,
        ?satisfyingCb  : String->Bool=null
    ) : Outcome<String, Error> 
        return Failure(new Error(I_am_a_Teapot, msg));

    public function menu<T>(
        items       : Array<Duet<String, T>>,
        title       : String="Please choose an entry from this menu",
        ?aAdditionalActions:Array<String>,
        ?menuOffset : MenuOffset=None,
        ?fItemOption: T->Array<MenuItemOption>=null
    ) : Outcome<Duet<String, Duet<String, T>>, Error>
        return Failure(new Error(I_am_a_Teapot, msg));

}
// vim: fdm=marker
