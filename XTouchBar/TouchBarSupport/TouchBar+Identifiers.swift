//
//  TouchBar+Identifiers.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 16/05/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

public extension NSTouchBar.CustomizationIdentifier {
  static let xTouchBar = NSTouchBar.CustomizationIdentifier("com.dominikbucher.Xtouchbar")
}

public extension NSTouchBarItem.Identifier {
  static let controlStripItem = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.controlStrip")

  static let editorContextJumpToDefinition = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.editorContext_jumpToDefinition:")
  static let fixAllIssues = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.fixAllIssues:")
  static let toggleTokenizedEditing = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.toggleTokenizedEditing:")
  static let toggleComments = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.toggleComments:")
  static let addDocumentation = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.addDocumentation:")
  static let openQuickly = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.openQuickly:")
  static let findAndReplaceInWorkspace = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.findAndReplaceInWorkspace:")
  static let showInspectorWithChoiceFromSender = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.showInspectorWithChoiceFromSender:")
  static let focusSelectedNodeAction = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.focusSelectedNodeAction:")
  static let GPUDebuggerZoomInCounterGraph = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.GPUDebugger_zoomInCounterGraph:")
  static let GPUDebuggerZoomOutCounterGraph = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.GPUDebugger_zoomOutCounterGraph:")
  static let toggleShowCodeReviewForEditor = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar._toggleShowCodeReviewForEditor:")
  static let foldCode = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.fold:")
  static let unfoldCode = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.unfold:")
}
