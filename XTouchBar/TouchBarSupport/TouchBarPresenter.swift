//
//  TouchBarPresenter.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

class TouchBarPresenter: NSObject, NSTouchBarDelegate, NSTouchBarProvider {
  public var touchBar: NSTouchBar? = NSTouchBar()

  #warning("This functionality is a bit hacky. Use at your own risk.")
  private lazy var item: NSTouchBarItem = {
    let item = NSCustomTouchBarItem(identifier: .controlStripItem)
    item.view = NSButton(title: "🐈", target: self, action: #selector(presentTouchBarOverFullContext))
    return item
  }()

  static var touchBarIdentifiers: [NSTouchBarItem.Identifier] = [
    .editorContextJumpToDefinition,
    .fixAllIssues,
    .toggleTokenizedEditing,
    .toggleComments,
    .addDocumentation,
    .openQuickly,
    .findAndReplaceInWorkspace,
    .GPUDebuggerZoomInCounterGraph,
    .GPUDebuggerZoomOutCounterGraph,
    .toggleShowCodeReviewForEditor,
    .unfoldCode,
    .foldCode
  ]

  static var itemsDictionary: [NSTouchBarItem.Identifier: Shortcut] = [
    .editorContextJumpToDefinition: Shortcut.jumpToDefinition,
    .fixAllIssues: Shortcut.fixAllIssues,
    .toggleTokenizedEditing: Shortcut.editAllInScope,
    .toggleComments: Shortcut.commentSelection,
    .addDocumentation: Shortcut.addDocumentation,
    .openQuickly: Shortcut.openQuickly,
    .findAndReplaceInWorkspace: Shortcut.findAndReplaceInWorkspace,
    .GPUDebuggerZoomInCounterGraph: Shortcut.zoomIn,
    .GPUDebuggerZoomOutCounterGraph: Shortcut.zoomOut,
    .toggleShowCodeReviewForEditor: Shortcut.showCodeReview,
    .foldCode: Shortcut.fold,
    .unfoldCode: Shortcut.unfold
  ]

  func clearUpTouchBar() {
    // Note, if you want the touchbar to cover just part of the screen and not hide the right control strip,
    // Use the other implementation which has the dafault parameter of `placement: 0` :)
    presentSystemModal(touchBar, placement: 0, systemTrayItemIdentifier: .controlStripItem)
    //    addButtonToControlStrip()
  }

  func hideXTouchBar() {
    dismissSystemModal(touchBar ?? NSTouchBar())
  }

  func makeTouchBar() {
    // To make native-like customization, we need to enable this.
    // Really works 2 times out of 5, but we have to live with that I guess...
    NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
    touchBar?.customizationIdentifier = .xTouchBar
  }

  func addButtonToControlStrip() {
    NSTouchBarItem.addSystemTrayItem(item)
    DFRElementSetControlStripPresenceForIdentifier(.controlStripItem, true)
  }

  @objc
  func presentTouchBarOverFullContext() {
    hideXTouchBar()
    NSTouchBarItem.removeSystemTrayItem(item)
    presentSystemModal(touchBar, placement: 1, systemTrayItemIdentifier: .flexibleSpace)
  }
  public override init() {
    super.init()
    touchBar?.delegate = self
    touchBar?.customizationIdentifier = .xTouchBar
    touchBar?.customizationAllowedItemIdentifiers = TouchBarPresenter.touchBarIdentifiers
    touchBar?.defaultItemIdentifiers = TouchBarPresenter.touchBarIdentifiers
  }
}

extension TouchBarPresenter {
  func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {

    guard let shortcut = TouchBarPresenter.itemsDictionary[identifier] else { return nil }

    let touchbarItem = NSButtonTouchBarItem(identifier: identifier)
    touchbarItem.customizationLabel = shortcut.itemDescription
    touchbarItem.image = shortcut.icon
    touchbarItem.target = shortcut
    touchbarItem.action = #selector(shortcut.runSelf)

    let touchBarToReplace = NSTouchBar()
    touchBarToReplace.delegate = self
    touchBarToReplace.defaultItemIdentifiers = TouchBarPresenter.touchBarIdentifiers
    return touchbarItem
  }
}
