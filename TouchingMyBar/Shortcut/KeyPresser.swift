//
//  KeyPresser.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 16/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import AppKit
import Carbon // Such Carbon, very Fiber

/// Protocol which has only one thing to do -> Perform shortcut command.
/// This should be responsible only to call the shortcut.
protocol KeyPresser {
    /// Performs  given shortcut on input with propriate modifiers like `cmd`, `shift`...
    /// - Parameter shortcut: `Shortcut` instance.
//    func perform(_ shortcut: Shortcut)
}

class MasterMind: KeyPresser {

    private lazy var funnyContext: NSTextInputContext = {
        let textView = NSTextView()
        let context = NSTextInputContext(client: textView)
        return context
    }()

    func perform(_ shortcut: Shortcut) {
         let group = DispatchGroup()
        // Hacks on top of hacks...
        // What's going on here?
        // We need to load what keyboard layout is the user using,
        // hence these 3 lines:

        funnyContext.selectedKeyboardInputSource = "com.apple.keylayout.USInternational-PC"
        // Then we change the keyboard layout to the "standart" ANSI US keyboard,
        // so our shortcuts (based on ANSI Key Codes) work properly.

        // Then we execute the shortcut:
        let keyCode = shortcut.key.rawValue
        // (Did try to do some googling, this should never fail unless we really fuckup.)
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

        group.enter()
        DispatchQueue.global().async {
            let flags = keyDownEvent.flags
            keyDownEvent.post(tap: .cgAnnotatedSessionEventTap)

            keyUpEvent.flags.insert(flags)
            keyUpEvent.post(tap: .cgAnnotatedSessionEventTap)

            group.leave()
        }

        group.wait()
        self.funnyContext.selectedKeyboardInputSource = UserDefaults.standard.string(forKey: "UserKeyboardLayout")
    }
}
