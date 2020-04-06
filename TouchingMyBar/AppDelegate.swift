//
//  AppDelegate.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 04/03/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Cocoa
import AppKit
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        TouchBarPresenter.shared.clearUpTouchBar()
		TouchBarPresenter.shared.makeButton()

        RegisterXcodeAppearanceObservers()
    }
}

extension TouchBarPresenter: NSTouchBarDelegate {
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        return nil
    }
}

// MARK: - Xcode obesrvations
private extension AppDelegate {
    /// Observes when Xcode is shown on the screen. Can occur at 3 scenarios.
    /// - `didLaunchApplicationNotification` (whenever Xcode is launched, presents our custom Touchbar App)
    /// - `didTerminateApplicationNotification` (when Xcode is terminated, will minimize the touchbarApp, but not kill it so it can appear again on previous sscenario)
    /// - `didActivateApplicationNotification` (when Xcode is toggled ass focus app.)
    func RegisterXcodeAppearanceObservers() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(hideOrShowXTouchBar), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(hideOrShowXTouchBar), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(hideOrShowXTouchBar), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }


    /// Pretty self-explanatory. Hides or shows Xtouchbar, see `RegisterXcodeAppearanceObservers()`'s documentations for more info.
    @objc func hideOrShowXTouchBar() {
        guard let appID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier else {
            TouchBarPresenter.shared.hideXTouchBar()
            return
        }

        if appID == Constants.AppIDs.xcode || appID == Constants.AppIDs.xTouchBar {
            TouchBarPresenter.shared.clearUpTouchBar()
        } else {
            TouchBarPresenter.shared.hideXTouchBar()
        }
    }
}
