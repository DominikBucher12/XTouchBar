//
//  AppDelegate.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 04/03/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  public var menuHolder = MenuCreatorImpl()
  public var touchbarPresenter = TouchBarPresenter()
  public var funnyTouchbarPresenter = FunnyTouchBarPresenter()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    touchbarPresenter.clearUpTouchBar()
    touchbarPresenter.makeTouchBar()
    menuHolder.start(with: touchbarPresenter)

    RegisterXcodeAppearanceObservers()
  }
}
// MARK: - Xcode observations
private extension AppDelegate {
  /// Observes when Xcode is shown on the screen. Can occur at 3 scenarios.
  /// - `didLaunchApplicationNotification` (whenever Xcode is launched, presents our custom Touchbar App)
  /// - `didTerminateApplicationNotification` (when Xcode is terminated, will minimize the touchbarApp, but not kill it so it can appear again)
  /// - `didActivateApplicationNotification` (when Xcode is toggled as focus app.)
  func RegisterXcodeAppearanceObservers() {
    [
      NSWorkspace.didLaunchApplicationNotification,
      NSWorkspace.didTerminateApplicationNotification,
      NSWorkspace.didActivateApplicationNotification
    ]
    .forEach {
      NSWorkspace.shared.notificationCenter.addObserver(
        self,
        selector: #selector(hideOrShowXTouchBar),
        name: $0,
        object: nil
      )
    }
  }

  /// Pretty self-explanatory. Hides or shows Xtouchbar, see `RegisterXcodeAppearanceObservers()`'s documentations for more info.
  @objc
  func hideOrShowXTouchBar() {
    guard let appID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else {
      touchbarPresenter.hideXTouchBar()
      return
    }

    if appID == Constants.AppIDs.xcode || appID == Constants.AppIDs.xTouchBar {
      touchbarPresenter.clearUpTouchBar()

    } else {
      touchbarPresenter.hideXTouchBar()
    }
  }
}
