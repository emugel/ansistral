package ansistral.modal;

/**
 * Options for items in menu().
 */
enum MenuItemOption {
    GrayedOut;
    // possible future options:
    // Tooltip(s:String);
    // Checked;
}

enum MenuOffset {
    OffsetId(s:String);         // menu() instantiated w/ id `s` remembers its selected/navigated index next time
    None;
}

/**
 * Default choice WHEN an interaction is possible.
 * With non-interactive implementations of confirm() and promptYesNo()
 *  this value will be IGNORED and DefaultChoiceForNonInteractive will 
 *  be examined instead.
 */
enum DefaultChoice {
    Yes;
    No;
    None;
}

/**
 * Used for promptYesNo() and confirm().
 * Default is Once. 
 * When response is not the default choice and `Twice` is passed,
 * it's considered a choice that needs to be verified by prompting a second
 * time.
 */
enum PromptCount {
    Once;
    Twice;          //  for sensitive tasks.   
                    //  to ask two confirmation if the result was not the default
                    //      "Delete user #3? [yes/NO] yes"
                    //      "Are you sure? [yes/NO] yes"  -> return The first response
                    //      "Are you sure? [yes/NO] no"   -> ask again the original question
                    //        "Failed to get a confirmation, asking again."
                    //
                    //      "Keep blog entry #4? [YES/no] no"
                    //      "Are you sure? [yes/NO] yes"
                    //
                    //  If there is no default:
                    //      "What do you think is the best color for this entry? [blue/red] blue"
                    //      "Are you sure? [yes/NO] no"
                    //    --> ask again
}


/**
 * Modal UI consist of simple questions blocking progress
 * until they have been answered (or until we consider it failed).
 *
 * Here are some implementations usable with setInstance:
 *   ansistral.modal.Modal.setInstance(new ansistral.modal.impl.ModalNonInteractive())
 *   ansistral.modal.Modal.setInstance(new ansistral.modal.impl.ModalAnsistral())
 * Possibly later one with coconut.
 *
 * [ModalNonInteractive() IS THE DEFAULT IMPLEMENTATION]
 *
 * In backends, running a 'script' from the CLI rather than 
 * from a daemonized system is the exception rather than the norm (at least for
 * us). It would be inacceptable to have such script locked waiting for 
 * some impossible user-interaction just because a programmer forgot to give it
 * a non-interactive implementation; hence the default is non-interactive;
 * if it's run and managed by a user you must either 
 * `Modal.setInstance(new ModalAnsistral())` or `Modal.enableInteractiveTUI()`.
 */
class Modal {

    static var _inst : ansistral.modal.IModal 
        = new ansistral.modal.impl.ModalNonInteractive();

    public static function getInstance() : ansistral.modal.IModal
        return _inst;

    public static function setInstance(impl:ansistral.modal.IModal) : ansistral.modal.IModal
        return _inst = impl;
    
    public static function enableInteractiveTUI() : ansistral.modal.IModal   // for convenience
        #if sys
        return _inst = new ansistral.modal.impl.ModalAnsistral();
        #else
        throw "ansistral text UI only available from sys targets";
        #end

}
