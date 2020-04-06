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
        TouchBarController.shared.clearUpTouchBar()
		TouchBarController.shared.makeButton()

        RegisterXcodeAppearanceObservers()
    }
}


class TouchBarController: NSObject {

    static let shared = TouchBarController()
    let touchBar = NSTouchBar()
    
    func clearUpTouchBar() {
        presentSystemModal(TouchBarController.shared.touchBar, placement: 1, systemTrayItemIdentifier: .controlStripItem)
    }
	
	func hideXTouchBar() {
		minimizeSystemModal(TouchBarController.shared.touchBar)
	}
	
	func makeButton() {
		let item = NSCustomTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: "HelloWorld"))
		item.view = NSHostingView(rootView: TouchBarContainer())
		
		TouchBarController.shared.touchBar.defaultItemIdentifiers = [item.identifier]
		TouchBarController.shared.touchBar.templateItems = [item]
	}

    private override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = []
    }
}

extension TouchBarController: NSTouchBarDelegate {
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
            TouchBarController.shared.hideXTouchBar()
            return
        }

        if appID == Constants.AppIDs.xcode || appID == Constants.AppIDs.xTouchBar {
            TouchBarController.shared.clearUpTouchBar()
        } else {
            TouchBarController.shared.hideXTouchBar()
        }
    }
}
