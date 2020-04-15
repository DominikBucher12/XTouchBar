//
//  PropertyListParser.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 11/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation

protocol PListParser {
    func parse(atPath path: String) -> [String: Any]
}

struct ShortcutObject: Codable {
    let action: String
    let alternate: Bool
    let commandID: String
    let group: String
    let groupID: String
    let groupedAlternate: Bool
    let keyboardShortcut: String?
    let navigation: Bool
    let title: String

    enum DecodingKey: String, CodingKey {
        case action = "Action"
        case alternate = "Alternate"
        case commandID = "CommandID"
        case group = "Group"
        case groupID = "GroupID"
        case groupedAlternate = "GroupedAlternate"
        case keyboardShortcut = "Keyboard Shortcut"
        case navigation = "Navigation"
        case title = "Title"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKey.self)
        let action: String = try container.decode(String.self, forKey: .action)
        let alternate: Bool = try container.decode(Bool.self, forKey: .alternate)
        let commandID: String = try container.decode(String.self, forKey: .commandID)
        let group: String = try container.decode(String.self, forKey: .group)
        let groupID: String = try container.decode(String.self, forKey: .groupID)
        let groupedAlternate: Bool = try container.decode(Bool.self, forKey: .groupedAlternate)
        let keyboardShortcut: String = try container.decode(String.self, forKey: .keyboardShortcut)
        let navigation: Bool = try container.decode(Bool.self, forKey: .navigation)
        let title: String = try container.decode(String.self, forKey: .title)

        self.init(
        action: action,
        alternate: alternate,
        commandID: commandID,
        group: group,
        groupID: groupID,
        groupedAlternate: groupedAlternate,
        keyboardShortcut: keyboardShortcut,
        navigation: navigation,
        title: title
        )
    }

    init(action: String, alternate: Bool, commandID: String, group: String, groupID: String, groupedAlternate: Bool, keyboardShortcut: String?, navigation: Bool, title: String) {
        self.action = action
        self.alternate = alternate
        self.commandID = commandID
        self.group = group
        self.groupID = groupID
        self.groupedAlternate = groupedAlternate
        self.keyboardShortcut = keyboardShortcut
        self.navigation = navigation
        self.title = title
    }
}

struct Parser: PListParser {
    func parse(atPath path: String) -> [String : Any] {
        var format = PropertyListSerialization.PropertyListFormat.xml
        let xml = FileManager.default.contents(atPath: path)!
        let plist = try! PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: &format) as! [String: AnyObject]
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
        } else if folderContents.first!.hasSuffix(".idekeybindings") {
            keyBindingsFileName = folderContents.first!
        }
        
        // We found .idekeybindings file, parse it.
        let dict = Parser().parse(
            atPath: "\(pathToFolder)\(keyBindingsFileName)"
            ) as! [String: [String: Any]]
        let array = dict["Menu Key Bindings"]?["Key Bindings"] as! [[String: Any]] // Really fuck you XML

        let result = array.map { element in
            ShortcutObject.init(
                action: element[ShortcutObject.DecodingKey.action.rawValue] as! String,
                alternate: false,//element[ShortcutObject.DecodingKey.alternate.rawValue] as! Bool,
                commandID: element[ShortcutObject.DecodingKey.commandID.rawValue] as! String,
                group: element[ShortcutObject.DecodingKey.group.rawValue] as! String,
                groupID: element[ShortcutObject.DecodingKey.groupID.rawValue] as! String,
                groupedAlternate: false,//element[ShortcutObject.DecodingKey.groupedAlternate.rawValue] as! Bool,
                keyboardShortcut: element[ShortcutObject.DecodingKey.keyboardShortcut.rawValue] as? String,
                navigation: false,//element[ShortcutObject.DecodingKey.navigation.rawValue] as! Bool,
                title: element[ShortcutObject.DecodingKey.title.rawValue] as! String
            )
        }
        print(result)
    }
}
