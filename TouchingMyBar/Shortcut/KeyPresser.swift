//
//  KeyPresser.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 16/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import AppKit

/// Protocol which has only one thing to do -> Perform shortcut command.
/// This should be responsible only to call the shortcut.
protocol KeyPresser {
    /// Performs  given shortcut on input with propriate modifiers like `cmd`, `shift`...
    /// - Parameter shortcut: `Shortcut` instance.
    func perform(_ shortcut: Shortcut)
}

struct MasterMind: KeyPresser {
    func perform(_ shortcut: Shortcut) {

        changeKeyboardLayout { context, usrLayout in
             // Then we execute the shortcut:
                   let keyCode = shortcut.key.rawValue
                   // (Did try to do some googling, this should never fail unless we really fuckup.)
                   guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
                       fatalError("\(#function) ducked up. Somehow Creating CGEvent failed. Check the keyCode: \(keyCode)")
                   }

                   for modifier in shortcut.modifiers {
                       switch modifier {
                       case .shift:   keyDownEvent.flags.insert(.maskShift)
                       case .control: keyDownEvent.flags.insert(.maskControl)
                       case .option:  keyDownEvent.flags.insert(.maskAlternate)
                       case .command: keyDownEvent.flags.insert(.maskCommand)
                       }
                   }
                   keyDownEvent.post(tap: .cgAnnotatedSessionEventTap)

                   // Don't forget to be a good platform citizen
                   // and "lift the fingers" of the virtual keyboard!
                   let flags = keyDownEvent.flags

                   guard let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
                       fatalError("\(#function) ducked up. Somehow Creating CGEvent failed. Check the keyCode: \(keyCode)")
                   }

                   keyUpEvent.flags.insert(flags)
                   keyUpEvent.post(tap: .cgAnnotatedSessionEventTap)

                   // And finally we change the keyboard layout back to whatever the user is using.
                   // (and of course we need to do it a bit later, because otherwise there's a possibility of wrong shortcut
                   // being executed because of a race condition)
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                       context.selectedKeyboardInputSource = usrLayout
                   }
        }
    }
    func changeKeyboardLayout(completion: (NSTextInputContext, NSTextInputSourceIdentifier) -> Void ) {
        // Hacks on top of hacks...
        // What's going on here?
        // We need to load what keyboard layout is the user using,
        // hence these 3 lines:
        let dummyViewToGetTheContext = NSTextView()
        let context = NSTextInputContext(client: dummyViewToGetTheContext)

        // Should never fail. That's what capitalism is built on.
        guard let usrLayout = context.selectedKeyboardInputSource else { return }

        // Then we change the keyboard layout to the "standart" ANSI US keyboard,
        // so our shortcuts (based on ANSI Key Codes) work properly.
        context.selectedKeyboardInputSource = "com.apple.keylayout.USInternational-PC"
        completion(context, usrLayout)
    }
}
