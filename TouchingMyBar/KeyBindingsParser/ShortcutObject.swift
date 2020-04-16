//
//  MenuKeyBinding.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 16/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// Object representing the shortcut in the plist.
/// We need to fetch this
struct MenuKeyBinding: Codable {
    let action: String
    let alternate: Bool
    let commandID: String
    let group: String?
    let groupID: String?
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

    init(
        action: String,
        alternate: Bool,
        commandID: String,
        group: String?,
        groupID: String?,
        groupedAlternate: Bool,
        keyboardShortcut: String?,
        navigation: Bool,
        title: String
    ) {
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

struct TextKeyBinding {
    let shortcut: String
    let action: String
}
