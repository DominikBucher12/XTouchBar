//
//  MenuCreator.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 22/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation
import SwiftUI
/// Implementation of the Menu
/// This instance holds everything about the menu
/// and is present whole time the AppDelegate is present (I am just poor iOS Dev, am I doing it right?)
class MenuCreatorImpl {
  private var window: NSWindow?
  var presenter: TouchBarPresenter?

  private var appMenu: NSMenu! // swiftlint:disable:this implicitly_unwrapped_optional
  private var statusItem: NSStatusItem! // swiftlint:disable:this implicitly_unwrapped_optional
  private let menuItems: [NSMenuItem] = [
    NSMenuItem(title: "Exit application", action: #selector(exit), keyEquivalent: ""),
    NSMenuItem(title: "About", action: #selector(about), keyEquivalent: ""),
    NSMenuItem(title: "Preferences", action: #selector(preferences), keyEquivalent: "")
  ]

  func start(with presenter: TouchBarPresenter) {
    setupMenuIcon()
    self.presenter = presenter
  }
}

// MARK: Setting up menu.
private extension MenuCreatorImpl {
    private func setupMenuIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: -1)

        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.title = "🆇"

        let menu = NSMenu(title: "XTouchBar")
        statusItem.menu = menu

        menuItems.forEach { item in
            item.target = self
            menu.addItem(item)
        }
        appMenu = menu
    }
}

// MARK: Actions

extension MenuCreatorImpl {

    @objc
    func about() {
        // Show Support
    }

    @objc
    func preferences() {
      NSApp.touchBar = presenter?.touchBar
      NSApplication.shared.toggleTouchBarCustomizationPalette(presenter)
    }

    @objc
    func exit() {
      NSApplication.shared.terminate(nil)
    }
}
