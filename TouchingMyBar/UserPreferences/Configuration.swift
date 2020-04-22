//
//  Configuration.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 22/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// User-defined configuration
/// Consists of name and the shortcuts which the user wants to use
/// on his beautiful touchbar.
struct Configuration: Codable {
    var name: String
    var shortcuts: [Shortcut]
    
    static let `default` = Configuration(
        name: "default",
        shortcuts: [
        .addDocumentation,
        .openQuickly,
        .commentSelection,
        .fixAllIssues,
        .editAllInScope
        ]
    )
}
