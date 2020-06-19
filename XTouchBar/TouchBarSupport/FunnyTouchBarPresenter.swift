//
//  FunnyTouchBarPresenter.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 19/06/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation
import Cocoa

class FunnyTouchBarPresenter: NSObject, NSTouchBarDelegate, NSTouchBarProvider {
  var touchBar: NSTouchBar?

  public override init() {
    super.init()
    touchBar = NSTouchBar()
    touchBar?.delegate = self
    touchBar?.customizationIdentifier = .magicBar
    touchBar?.defaultItemIdentifiers = [.exitItem, .magicControlStripItem]
    touchBar?.customizationAllowedItemIdentifiers = [.magicControlStripItem]
  }

  func clearUpTouchBar() {
     // Note, if you want the touchbar to cover just part of the screen and not hide the right control strip,
     // Use the other implementation which has the dafault parameter of `placement: 0` :)
     presentSystemModal(touchBar, placement: 1, systemTrayItemIdentifier: .controlStripItem)
     //    addButtonToControlStrip()
   }

  func hideXTouchBar() {
    dismissSystemModal(touchBar ?? NSTouchBar())
  }

  public func createFunnyTouchBar() {
    hideXTouchBar()
    clearUpTouchBar()
  }

  func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
     // Thanks https://fuckingifcaseletsyntax.com
    if case .magicControlStripItem = identifier {
      let customViewItem = NSCustomTouchBarItem(identifier: identifier)
      let niceView = FunnyView(
        frame: NSRect(x: 0, y: 0, width: Constants.TouchBar.width, height: Constants.TouchBar.height)
      )
      niceView.wantsLayer = true
      customViewItem.view = niceView
      return customViewItem
    }
    let exitItem = NSButtonTouchBarItem(
      identifier: .exitItem,
      title: "EXIT",
      target: self,
      action: #selector(self.setBackClassicTouchBar)
    )
    return exitItem
  }

  @objc
  public func setBackClassicTouchBar() {
    (NSApp.delegate as? AppDelegate)?.funnyTouchbarPresenter.hideXTouchBar()
    (NSApp.delegate as? AppDelegate)?.touchbarPresenter.makeTouchBar()
    (NSApp.delegate as? AppDelegate)?.touchbarPresenter.clearUpTouchBar()
  }
}
