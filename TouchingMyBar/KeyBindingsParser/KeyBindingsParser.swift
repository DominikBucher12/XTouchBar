//
//  KeyBindingsParser.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 11/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation

protocol PListParser {
    func parse(atPath path: String) -> [String: Any]
}

struct Parser: PListParser {
    func parse(atPath path: String) -> [String: Any] {
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let xml = FileManager.default.contents(atPath: path),
              let plist = try? PropertyListSerialization.propertyList(
                from: xml,
                options: .mutableContainersAndLeaves,
                format: &format
                ) as? [String: AnyObject]
        else { fatalError("Dafuq") }
        return plist
    }
}

enum ParsingError: Error {
    case noKeyBindingsFileFound
    case moreThanOneKeyBindingsFileFound
}

struct PListProcessor {
    static func process() throws {
        // Find some .idekeybindings file to parse.
        // If there is none or more than one, throw ParsingError.
        let fm = FileManager.default
        let homeDir = NSHomeDirectory()
        let pathToFolder = "\(homeDir)/Library/Developer/Xcode/UserData/KeyBindings/"
        var keyBindingsFileName = ""
        
        let folderContents: [String] = {
            if let contents = try? fm.contentsOfDirectory(atPath: pathToFolder) {
                return contents
            }
            return [""]
        }()
        
        if folderContents.isEmpty {
            throw ParsingError.noKeyBindingsFileFound
        } else if folderContents.count > 1 {
            var idekeybindingsFilesCount = 0
            
            for file in folderContents {
                if idekeybindingsFilesCount > 1 { throw ParsingError.moreThanOneKeyBindingsFileFound }
                if file.hasSuffix(".idekeybindings") {
                    idekeybindingsFilesCount += 1
                    keyBindingsFileName = file
                }
            }
        } else if let first = folderContents.first, first.hasSuffix(".idekeybindings") {
            keyBindingsFileName = first
        }
        
        // We found .idekeybindings file, parse it.
        guard let dict = Parser().parse(atPath: "\(pathToFolder)\(keyBindingsFileName)") as? [String: [String: Any]],
              let array = dict["Menu Key Bindings"]?["Key Bindings"] as? [[String: Any]] // Really fuck you XML
        else { return }

        let result = array.map { element in
            // We do really care about action, commandID, keyboard shortcut and title :D
            // Dunno why I added the other stuff around :D :D
            guard let action = element[ShortcutObject.DecodingKey.action.rawValue] as? String,
                  let commandID = element[ShortcutObject.DecodingKey.commandID.rawValue] as? String,
                  let title = element[ShortcutObject.DecodingKey.title.rawValue] as? String
            else { return }

            ShortcutObject(
                action: action,
                alternate: false, //element[ShortcutObject.DecodingKey.alternate.rawValue] as! Bool,
                commandID: commandID,
                group: element[ShortcutObject.DecodingKey.group.rawValue] as? String,
                groupID: element[ShortcutObject.DecodingKey.groupID.rawValue] as? String,
                groupedAlternate: false, //element[ShortcutObject.DecodingKey.groupedAlternate.rawValue] as! Bool,
                keyboardShortcut: element[ShortcutObject.DecodingKey.keyboardShortcut.rawValue] as? String,
                navigation: false, //element[ShortcutObject.DecodingKey.navigation.rawValue] as! Bool,
                title: title
            )
        }
        print(result)
    }
}
