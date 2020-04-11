//
//  Shortcut.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 08/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// Protocol which has only one thing to do -> Perform shortcut command.
/// This should be responsible only to call the shortcut.
protocol KeyPresser {
    /// Performs  given shortcut on input with propriate modifiers like `cmd`, `shift`...
    /// - Parameter shortcut: `Shortcut` instance.
    func perform(_ shortcut: Shortcut)
}

extension KeyPresser {

    func perform(_ shortcut: Shortcut) {

        let keyCode: UInt16 = shortcut.key.rawValue
        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            #warning("TODO: Do we just crash or handle this somehow? 🤔")
            fatalError("Messed something up...")
        }

        for modifier in shortcut.modifiers {
            switch modifier {
            case .shift:   keyDownEvent.flags.insert(.maskShift)
            case .control: keyDownEvent.flags.insert(.maskControl)
            case .option:  keyDownEvent.flags.insert(.maskAlternate)
            case .command: keyDownEvent.flags.insert(.maskCommand)
            }
        }
        keyDownEvent.post(tap: .cghidEventTap)
    }
}

/// Purest form of shortcut.
/// In real life, shortcut consists of some keys (like `cmd + a`, or `cmd + shift + o`)
/// In here, we divide the shortcut into actual pure keys (like letters, numbers, commas...)
/// and modifiers (The fancy keys like `cmd`, `control`, `shift`, `alt`)
struct Shortcut {
    /// The shortcuts identifier. Pretty self-explanatory.
    let id: String
    /// Just simple key -> `a`, `y`, `,`, `=`, `+`
    let key: Key
    /// Set of Modifier(s), the more fancier: `cmd`, `shift`, `control`, `alt`,???
    /// Set because it's fancy and doesn't contain duplicates
    let modifiers: Set<KeyModifier>

    public static var openFileQuickly: Shortcut {
        #warning("FIX ME!!!")
        return Shortcut(id: "BOGUS_ID", key: .O, modifiers: [.command, .shift])
    }
    public static var openFile: Shortcut {
        #warning("FIX ME!!!")
        return Shortcut(id: "BOGUS_ID", key: .O, modifiers: [.command])
    }
}
