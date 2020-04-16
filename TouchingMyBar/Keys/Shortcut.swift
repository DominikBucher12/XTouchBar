//
//  Shortcut.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 08/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

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
