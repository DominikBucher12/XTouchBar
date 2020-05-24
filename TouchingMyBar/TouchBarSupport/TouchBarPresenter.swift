//
//  TouchBarPresenter.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

class TouchBarPresenter: NSObject, NSTouchBarDelegate, NSTouchBarProvider {
  public var touchBar: NSTouchBar? = NSTouchBar()

  private lazy var item: NSTouchBarItem = {
    let item = NSCustomTouchBarItem(identifier: .controlStripItem)
    #warning("Figure out the icon for this, I like cats :D")
    item.view = NSButton(title: "🐈", target: self, action: #selector(presentTouchBarOverFullContext))
    return item
  }()

  func clearUpTouchBar() {
    // Note, if you want the touchbar to cover just part of the screen and not hide the right control strip,
    // Use the other implementation which has the dafault parameter of `placement: 0` :)
    presentSystemModal(touchBar, placement: 0, systemTrayItemIdentifier: .controlStripItem)
    addButtonToControlStrip()
  }

  func hideXTouchBar() {
    dismissSystemModal(touchBar ?? NSTouchBar())
  }

  func makeTouchBar() {
    // To make native-like customization, we need to enable this.
    NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
    #warning("Identify problem with identifiers 😓")
    touchBar?.customizationIdentifier = .xTouchBar
    //        let item = NSCustomTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: "XTouchBar"))
    //        TouchBarPresenter.shared.touchBar.defaultItemIdentifiers = [item.identifier]
    //        TouchBarPresenter.shared.touchBar.templateItems = [item]
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
    touchBar?.customizationAllowedItemIdentifiers =  [
         .editorContextJumpToDefinition,
         .fixAllIssues,
         .toggleTokenizedEditing,
         .toggleComments,
         .addDocumentation,
         .openQuickly,
         .findAndReplaceInWorkspace,
         .showInspectorWithChoiceFromSender,
         .focusSelectedNodeAction,
         .GPUDebuggerZoomInCounterGraph,
         .GPUDebuggerZoomOutCounterGraph,
         .toggleShowCodeReviewForEditor
    ]
    touchBar?.defaultItemIdentifiers =  [
      .editorContextJumpToDefinition,
      .fixAllIssues,
      .toggleTokenizedEditing,
      .toggleComments,
      .addDocumentation,
      .openQuickly,
      .findAndReplaceInWorkspace,
      .showInspectorWithChoiceFromSender,
      .focusSelectedNodeAction,
      .GPUDebuggerZoomInCounterGraph,
      .GPUDebuggerZoomOutCounterGraph,
      .toggleShowCodeReviewForEditor
    ]
  }
}

extension TouchBarPresenter {
 func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {

          switch identifier {
          default:
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            popoverItem.customizationLabel = "Something"
            popoverItem.collapsedRepresentationLabel = "Something"

            let secondaryTouchBar = NSTouchBar()
            secondaryTouchBar.delegate = self
            secondaryTouchBar.defaultItemIdentifiers = [.fixAllIssues]

            // We can setup a different NSTouchBar instance for popoverTouchBar and pressAndHoldTouchBar property
            // Here we just use the same instance.
            //
            popoverItem.pressAndHoldTouchBar = secondaryTouchBar
            popoverItem.popoverTouchBar = secondaryTouchBar

            return popoverItem
          }
      }
}
