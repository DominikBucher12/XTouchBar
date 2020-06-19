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
    iconData: nil,
    backgroundColor: .red,
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
//    let newTouchBar = NSTouchBar()
//    presentSystemModal(NSTouchBar(), placement: 1, systemTrayItemIdentifier: .controlStripItem)
  }

}
