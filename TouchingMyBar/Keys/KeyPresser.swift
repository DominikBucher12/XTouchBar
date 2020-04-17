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
    func perform(_ shortcut: Shortcut)
}

struct MasterMind: KeyPresser {
    func perform(_ shortcut: Shortcut) {
        let keyCode = shortcut.key.rawValue
        // Did try to do some googling, this should never fail unless we really fuckup.
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
        keyDownEvent.post(tap: .cghidEventTap)
        
        // Don't forget to be a good platform citizen
        // and "lift the fingers" of the virtual keyboard.
        let flags = keyDownEvent.flags
        
        guard let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
            fatalError("\(#function) ducked up. Somehow Creating CGEvent failed. Check the keyCode: \(keyCode)")
        }
        
        keyUpEvent.flags.insert(flags)
        keyUpEvent.post(tap: .cghidEventTap)
    }
}
