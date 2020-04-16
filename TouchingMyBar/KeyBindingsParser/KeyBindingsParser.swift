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
        guard let dict = Parser().parse(atPath: "\(pathToFolder)\(keyBindingsFileName)") as? [String: [String: Any]] else { return }

        if let menuKeyBindingsArray = dict["Menu Key Bindings"]?["Key Bindings"] as? [[String: Any]] {
            let result = menuKeyBindingsArray.compactMap { element -> MenuKeyBinding? in
                // We do really care about action, commandID, keyboard shortcut and title :D
                // Dunno why I added the other stuff around :D :D
                guard let action = element[MenuKeyBinding.DecodingKey.action.rawValue] as? String,
                      let commandID = element[MenuKeyBinding.DecodingKey.commandID.rawValue] as? String,
                      let title = element[MenuKeyBinding.DecodingKey.title.rawValue] as? String
                else { return nil }

                return MenuKeyBinding(
                    action: action,
                    alternate: false, //element[MenuKeyBinding.DecodingKey.alternate.rawValue] as! Bool,
                    commandID: commandID,
                    group: element[MenuKeyBinding.DecodingKey.group.rawValue] as? String,
                    groupID: element[MenuKeyBinding.DecodingKey.groupID.rawValue] as? String,
                    groupedAlternate: false, //element[MenuKeyBinding.DecodingKey.groupedAlternate.rawValue] as! Bool,
                    keyboardShortcut: element[MenuKeyBinding.DecodingKey.keyboardShortcut.rawValue] as? String,
                    navigation: false, //element[MenuKeyBinding.DecodingKey.navigation.rawValue] as! Bool,
                    title: title
                )
            }
            print(result)
        }

        if let textKeyBinding = dict["Text Key Bindings"]?["Key Bindings"] as? [String: Any] {
            let nextResult = textKeyBinding.map { key, value -> TextKeyBinding in
                // swiftlint:disable:next force_cast
                TextKeyBinding(shortcut: key, action: value as! String)
            }
        }

        // YOLO Hacks
//        result.forEach { object in
//            print("static let \(object.title.lowerCamelCased) = Shortcut(id: \"\(object.action)\", key: .O, modifiers: [.command])")
//        }
    }
}

extension String {

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    var upperCamelCased: String {
        return self.lowercased()
            .split(separator: " ")
            .map { return $0.lowercased().capitalizingFirstLetter() }
            .joined()
    }

    var lowerCamelCased: String {
        let upperCased = self.upperCamelCased
        return upperCased.prefix(1).lowercased() + upperCased.dropFirst()
    }
}
