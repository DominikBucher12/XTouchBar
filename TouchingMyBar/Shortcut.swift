//
//  Shortcut.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 08/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

protocol Performable {
    func perform(_ shortcut: Shortcut)
}

extension Performable {

    func perform(_ shortcut: Shortcut) {

        let KeyCode: UInt16 = shortcut.key.rawValue
        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: KeyCode, keyDown: true) else {
            #warning("TODO: Do we just crash or handle this somehow? 🤔")
            fatalError("Messed something up...")
        }

        var flags = CGEventFlags()

        for modifier in shortcut.modifiers {
            switch modifier {
            case .shift:
                flags.insert(.maskShift)
            case .control:
                flags.insert(.maskControl)
            case .option:
                flags.insert(.maskAlternate)
            case .command:
                flags.insert(.maskCommand)
            }
        }

        keyDownEvent.flags = flags
        keyDownEvent.post(tap: .cghidEventTap)
    }
}

struct Shortcut {
    let key: Key
    let modifiers: [KeyModifier]
}
