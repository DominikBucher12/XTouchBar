//
//  AppDelegate.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 04/03/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        TouchBarController.shared.clearUpTouchBar()

        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

class TouchBarController: NSObject {

    static let shared = TouchBarController()
    let touchBar = NSTouchBar()
    
    func clearUpTouchBar() {
        presentSystemModal(TouchBarController.shared.touchBar, placement: 1, systemTrayItemIdentifier: .controlStripItem)
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
