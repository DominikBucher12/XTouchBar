//
//  Shortcut+MostUsefulToolOnEarth.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 12/06/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation

extension Shortcut {
  static let mostUsefulButtonOnEarth = Shortcut(
    iconData: "🧙🏻‍♂️".emojiImage()?.tiffRepresentation,
    id: "makeMagicHappen:",
    key: .escape, // 🏃‍♂️ Escape while you can
    modifiers: [],
    itemDescription: "Does anything that you desire.",
    kind: .button(action: Actions.makeMagic)
  )
}

/// Thefuck am I doing :D
enum Actions {
  static let makeMagic: () -> Void = {
    (NSApp.delegate as? AppDelegate)?.funnyTouchbarPresenter.createFunnyTouchBar()
  }
}

public extension NSTouchBarItem.Identifier {
  static let magicControlStripItem = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.magicControlItem")
  static let exitItem = NSTouchBarItem.Identifier("com.dominikbucher.xcodebar.exit")
}
public extension NSTouchBar.CustomizationIdentifier {
  static let magicBar = NSTouchBar.CustomizationIdentifier("com.dominikbucher.xcodebar.magicControlItem")
}
