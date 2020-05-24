//
//  NSTouchbarSupport.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 07/03/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// This function replaces the current touchbar with custom implementation, keep in mind it should be the same touchbar as
/// `TouchBarController.shared.touchbar` otherwise you will have a bad time.
/// - Parameters:
///   - touchBar: Touchbar instance which to present
///   - identifier: The touchbar identifier, should be no other than the app identifier revers dns+touchbar 👮🏻‍♂️
func presentSystemModal(_ touchBar: NSTouchBar!, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
  NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: identifier)
}

/// This function replaces the current touchbar with custom implementation, keep in mind it should be the same touchbar as
/// `TouchBarController.shared.touchbar` otherwise you will have a bad time.
/// - Parameters:
///   - touchBar: Touchbar instance which to present
///   - identifier: The touchbar identifier, should be no other than the app identifier revers dns+touchbar 👮🏻‍♂️
func presentSystemModal(_ touchBar: NSTouchBar!, placement: Int64, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
  NSTouchBar.presentSystemModalTouchBar(touchBar, placement: placement, systemTrayItemIdentifier: identifier)
}

func dismissSystemModal(_ touchBar: NSTouchBar) {
  NSTouchBar.dismissSystemModalTouchBar(touchBar)
}

/// Minimize the system touchbar, make it go away, you don't want this :D
/// - Parameter touchBar: The touchbar to minimize.
func minimizeSystemModal(_ touchBar: NSTouchBar!) {
  NSTouchBar.minimizeSystemModalTouchBar(touchBar)
}
