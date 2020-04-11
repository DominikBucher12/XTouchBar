//
//  UserDefinedShortcutsParser.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 09/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation

enum ParsingError: Error {
    case couldNotReadFile
}

final class UserDefinedShortcutsParser {
    
    private let fileToParse: String
    
    private var shortcuts = [Shortcut]()
    
    private var shortcutKeyBindings = [String]()
    private var shortcutIDs         = [String]()
    
    private let fm = FileManager.default
    
    public init() throws {
        let pathFromHome = "Library/Developer/Xcode/UserData/KeyBindings/Really retarded Keybinding.idekeybindings"
        let url = fm.homeDirectoryForCurrentUser.appendingPathComponent(pathFromHome)
        
        do {
            fileToParse = try String(contentsOf: url, encoding: .utf8)
        } catch {
            assertionFailure("ERROR IN UserDefinedShortcutsParser.init() :: thrown: \(error)")
            throw ParsingError.couldNotReadFile
        }
        
        self.parseFile()
        let s = self.parseShortcutsAndIDs()

        #warning("Delete")
        print("SHORTCUTS:", s)
    }
    
    private func parseFile() {
        let textKeyBindings = "<key>Text Key Bindings</key>"
        let menuKeyBindings = "<key>Menu Key Bindings</key>"
        let keyBindings     = "<key>Key Bindings</key>"
        
        var buf = ""
        var shouldInspectTag = false
        
        var enteredTextKeyBindingsSection  = false
        var enteredMenuKeyBindingsSection  = false
        
        var startLookingForShortcutsInTextKeyBindings = false
        var startLookingForShortcutsinMenuKeyBindings = false
        
        var isInDictTag = false
        
        var nextOneIsAction = false
        var nextOneIsKeyboardShortcut = false
        
        for char in fileToParse {
            if char == "<" {
                shouldInspectTag = true
            } else if char == "\n" {
                shouldInspectTag = false
            }
            
            if startLookingForShortcutsinMenuKeyBindings && !shouldInspectTag {
                
                if buf.hasPrefix("<string>") && nextOneIsAction	{
                    buf.removeFirst(8)
                    buf.removeLast(9)
                    shortcutIDs.append(buf)
                    nextOneIsAction = false
                } else if buf.hasPrefix("<string>") && nextOneIsKeyboardShortcut {
                    buf.removeFirst(8)
                    buf.removeLast(9)
                    shortcutKeyBindings.append(buf)
                    nextOneIsKeyboardShortcut = false
                }
                
                if buf == "<key>Action</key>" {
                    nextOneIsAction = true
                } else if buf == "<key>Keyboard Shortcut</key>" {
                    nextOneIsKeyboardShortcut = true
                }
                
            } else if startLookingForShortcutsInTextKeyBindings && !shouldInspectTag {
                if buf.hasPrefix("<key>") && isInDictTag {
                    buf.removeFirst(5)
                    buf.removeLast(6)
                    shortcutKeyBindings.append(buf)
                } else if buf.hasPrefix("<string>") && isInDictTag {
                    buf.removeFirst(8)
                    buf.removeLast(9)
                    shortcutIDs.append(buf)
                }
                
            } else if buf == keyBindings {
                
                if enteredTextKeyBindingsSection {
                    startLookingForShortcutsInTextKeyBindings = true
                    startLookingForShortcutsinMenuKeyBindings = false
                } else if enteredMenuKeyBindingsSection {
                    startLookingForShortcutsInTextKeyBindings = false
                    startLookingForShortcutsinMenuKeyBindings = true
                }
            }
            
            if buf == "<dict>" {
                isInDictTag = true
            } else if buf == "</dict>" {
                isInDictTag = false
            }
            
            if buf == menuKeyBindings {
                enteredTextKeyBindingsSection = false
                enteredMenuKeyBindingsSection = true
                
                startLookingForShortcutsInTextKeyBindings = false
                startLookingForShortcutsinMenuKeyBindings = false
            } else if buf == textKeyBindings {
                enteredTextKeyBindingsSection = true
                enteredMenuKeyBindingsSection = false
                
                startLookingForShortcutsInTextKeyBindings = false
                startLookingForShortcutsinMenuKeyBindings = false
            }
            
            if shouldInspectTag {
                buf.append(char)
            } else {
                buf = ""
            }
        }
        
    }
    
    private func parseShortcutsAndIDs() -> [Shortcut] {
        
        var shortcuts = [Shortcut]()
        
        for i in 0..<shortcutKeyBindings.count {
            let id = shortcutIDs[i]
            
//            var key: Key?
            var modifiers = Set<KeyModifier>()
            
            for character in shortcutKeyBindings[i] {
                switch character {
                case "^": modifiers.insert(.control)
                case "$": modifiers.insert(.shift)
                case "~": modifiers.insert(.option)
                case "@": modifiers.insert(.command)
                default: () // TODO: Handle characters
                }
            }
            
            //            if let key = key {
            let s = Shortcut(id: id, key: .A, modifiers: modifiers)
            shortcuts.append(s)
            //            } else {
            //                preconditionFailure("FAILED TO CORRECTLY READ CHARACTER USED IN SHORTCUT")
            //            }
            
        }
        
        return shortcuts
    }
    
}
