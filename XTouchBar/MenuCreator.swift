//
//  MenuCreator.swift
//  XTouchBar
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

  private var presenter: TouchBarPresenter?
  private var touchbarIsVisible = false

  private var appMenu: NSMenu! // swiftlint:disable:this implicitly_unwrapped_optional
  private var statusItem: NSStatusItem! // swiftlint:disable:this implicitly_unwrapped_optional
  private let menuItems: [NSMenuItem] = [
    NSMenuItem(title: "Exit application", action: #selector(exit), keyEquivalent: ""),
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
  func preferences() {
    NSApp.touchBar = presenter?.touchBar
    addCustomizationObservers()
    // Need to activate XTouchBar application, otherwise funny stuff happens in Cusomization pallete.
    NSApp.activate(ignoringOtherApps: true)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
      NSApplication.shared.toggleTouchBarCustomizationPalette(self.presenter)
    }
  }

  @objc
  func exit() {
    NSApplication.shared.terminate(nil)
  }

  // MARK: - Black magic
  // don't ask me how this works, spent too much time searching for documentation which doesn't exist.
  @objc
  func willEnterCustomization(_ notification: NSNotification) {
    if let touchbar = presenter?.touchBar {
      dismissSystemModal(touchbar)
    }
    NSApp.touchBar = presenter?.touchBar
  }

  @objc
  func didExitCustomization(_ notification: NSNotification) {
    NSApp.touchBar = nil
    if let touchbar = presenter?.touchBar {
      dismissSystemModal(touchbar)
    }
    removeCustomizationObservers()
    presenter?.clearUpTouchBar()
    presenter?.makeTouchBar()
  }
}

private extension MenuCreatorImpl {
  private func addCustomizationObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willEnterCustomization(_:)),
      name: NSNotification.Name("NSTouchBarWillEnterCustomization"),
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didExitCustomization(_:)),
      name: NSNotification.Name("NSTouchBarDidExitCustomization"),
      object: nil)
  }

  private func removeCustomizationObservers() {
    NotificationCenter.default.removeObserver(
      self,
      name: NSNotification.Name("NSTouchBarWillEnterCustomization"),
      object: nil
    )
    NotificationCenter.default.removeObserver(
      self,
      name: NSNotification.Name("NSTouchBarDidExitCustomization"),
      object: nil
    )
  }
}
