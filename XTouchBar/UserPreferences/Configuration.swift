//
//  Configuration.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 22/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// User-defined configuration
/// Consists of name and the shortcuts which the user wants to use
/// on his beautiful touchbar.
#warning("Probably not needed? Touchbar private API handles this for us somehow.")
struct Configuration: Codable {
  /// Name of the config
  var name: String
  /// The Shortcuts stored in the configuration
  var shortcuts: [Shortcut]
  /// Set to true if you want the tool to cover whole touchbar and delete the ControlStrip.
  ///
  /// `coversFullTouchBar ? [[XTB]] : [[XTB]] [CONTROL STRIP]]`
  var coversFullTouchBar: Bool = false

  /// Default configuration of the XTouchBar
  /// It should contain all you need and maybe more :)
  static let `default` = Configuration(
    name: "default",
    shortcuts: [
      .addDocumentation,
      .openQuickly,
      .commentSelection,
      .fixAllIssues,
      .editAllInScope,
      .jumpToDefinition
    ]
  )

  static let krossConfig = Configuration(
    name: "krossConfig",
    shortcuts: [
      .addDocumentation,
      .commentSelection,
      .fixAllIssues,
      .editAllInScope,
      .jumpToDefinition,
      .findInWorkspace
    ]
  )
}
