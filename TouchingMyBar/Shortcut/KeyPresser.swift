//
//  KeyPresser.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 16/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// Protocol which has only one thing to do -> Perform shortcut command.
/// This should be responsible only to call the shortcut.
protocol KeyPresser {
    /// Performs  given shortcut on input with propriate modifiers like `cmd`, `shift`...
    /// - Parameter shortcut: `Shortcut` instance.
    static func perform(_ shortcut: Shortcut)
}

#warning("Before release go through history and probably make some list of articles to thank.")
/// RANT AHEAD, read at your own risk. @dbucher
///
///
/// There goes my darkest developer moment in my 5 year history. After going through about 50 resources how to wait for
/// `CGEvent.post` to complete yes it does some nasty Async stuff instead, probably queing somewhere in the dark macOS world
/// I just gave up and put briliant `Thread.sleep(forTimeInterval:)` because spending more than 3 weekends on almost-ready thing
/// is against my believes (even though I spend much more sometimes when I don't wanna achieve something in a non hacky way)
/// Anyway this whole project is just hack.
/// The best way to create this project would be class-dumping the `IDEKit`, `DVTKit` and `IDEFoundation`, Implement almost all the headers
/// Simulate `IDEApplication` run from there get the `EditorMenuDelegate` instance,
/// cache all the commands from `CommandManager` (I believe it loads on some calls in `EditorMenuDelegate`.)
/// Then there is `_activateMenuKeyBindingSetWithMenuDefinitionExtensionIdentifiers` and we are almost at it (this activates the reverse-dns stuff
/// we need to have loaded in order to call for instance com.apple.PegasusEditor(What the fuck).addDocumentation)
/// I believe the next steps would be to sacrifice unicorn and ride T-Rex to Cuppertino to get some secret framework or wtf.
///
/// I have gone this far and I believe it is just 3 steps to do this, but I don't really have capacity to continue with
/// Linking and running whole Xcode again just for this pet project. One day I might create separate branch which has IDEKit implementation
/// instead of this key-logging stuff.
///
/// If you, alongside with me, until this point have dreamed on working on Xcode at Apple one day, I am sorry to crush all your hopes and dreams. 😭
/// Anyway here we go how this works.
///
/// # How it all works:
///
/// On input, we get our custom-defined `Shortcut` object which gives us the key and the modifiers
/// When we get those, because there is really no not-retarded first-party API to call shortcuts we create
/// CGEvent from the virtual key code. After the event is created, we iterate through the set of identifiers,
/// add them to the `keyPress` event. If you think we would just press the virtual button afterwards,you are a lot wrong.
/// This is where things get a lot funny and I really couldn't find any satisfying solution to the problem
/// (Because `CGEvent.post` is async :) Thanks Apple)
/// After that, we set the layout of keyboard on the context of our virtual `textView` to `USInternational-PC` because someone
/// could code in different language (I have a confession to make)
/// We need to wait some time for this to process, because it appears it's async operation too.
/// After that, we press finally the virtual keyCode with the modifiers and voila - the shortcut is called as a magic.
/// Because we are good people, we lift the button too.
/// We need to wait some time because the posting costs us some time as well. So we just wait.
/// After all the keys are lift up, we just set the keyboard to the one we fetched when the application was started in `ApplicationDelegate`
/// This process goes over and over as you are happy and press the buttons.
///
/// I feel really ashamed that I couldn't come up with some better solution than changing the keyboard layout and then waiting
/// To free my conscious I post here some of the resources I found:
///
/// https://lists.apple.com/archives/cocoa-dev/2009/Jun/msg01008.html
/// https://stackoverflow.com/questions/48588808/waiting-for-an-programmatic-key-press-to-be-processed
///
/// And my thanks goes to this unknown guy https://gist.github.com/osnr/23eb05b4e0bcd335c06361c4fabadd6f
/// and this one https://github.com/naru-jpn/KeyboardSimulator/blob/master/KeyboardSimulator/Classes/KeyboardSimulator.swift
/// Also this project helped me as a great documentation https://github.com/shpakovski/MASShortcut
///
enum MasterMind: KeyPresser {

    /// This is our dummy for Getting `NSTextInputContext`. `NSTextInputContext` is a great way to change users
    /// input without them knowing (For fun, you can create some macOS app with textField, set them keyboard layout to `QWERTY JIS Layout` to use
    /// Kana` and then watch the reactions of the ppl 🦹🏼‍♂️
    private static var funnyContext: NSTextInputContext = {
        let textView = NSTextView() // Probably too heavy, could only just be object implementing `NSTextInputClient`
        let context = NSTextInputContext(client: textView)
        return context
    }()

    /// Performs a shurtcut.
    /// - Parameter shortcut: Shortcut instance to get :) Take a look at Shortcut.swift
    static func perform(_ shortcut: Shortcut) {
        let keyCode = shortcut.key.rawValue

        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            fatalError("\(#function) ducked up. Somehow Creating CGEvent failed. Check the keyCode: \(keyCode)")
        }

        for modifier in shortcut.modifiers {
            switch modifier {
            case .shift: keyDownEvent.flags.insert(.maskShift)
            case .control: keyDownEvent.flags.insert(.maskControl)
            case .option: keyDownEvent.flags.insert(.maskAlternate)
            case .command: keyDownEvent.flags.insert(.maskCommand)
            }
        }

        // Don't forget to be a good platform citizen
        // and "lift the fingers" of the virtual keyboard!
        guard let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
            fatalError("\(#function) ducked up. Somehow Creating CGEvent failed. Check the keyCode: \(keyCode)")
        }

        funnyContext.selectedKeyboardInputSource = Constants.Configuration.usKeyboardLayout
        Thread.sleep(forTimeInterval: 1.0e-2) // See this enum description.

        let flags = keyDownEvent.flags
        keyDownEvent.post(tap: .cgAnnotatedSessionEventTap)

        keyUpEvent.flags.insert(flags)
        keyUpEvent.post(tap: .cgAnnotatedSessionEventTap)

        Thread.sleep(forTimeInterval: 1.0e-2) // See this enum description.
        funnyContext.selectedKeyboardInputSource = UserDefaults.standard.string(forKey: Constants.Configuration.keyboardLayoutKey)
    }
}
