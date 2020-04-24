//
//  MenuCreator.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 22/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation
import SwiftUI

protocol MenuCreator {
    func start()
}

class MenuCreatorImpl: MenuCreator {
    private var window: NSWindow?
    private var contentView = PreferencesUI()
    private let tbMasterController: TouchBarMasterController

    private var appMenu: NSMenu! // swiftlint:disable:this implicitly_unwrapped_optional
    private var statusItem: NSStatusItem! // swiftlint:disable:this implicitly_unwrapped_optional
    private let menuItems: [NSMenuItem] = [
        NSMenuItem(title: "Exit application", action: #selector(exit), keyEquivalent: ""),
        NSMenuItem(title: "About", action: #selector(about), keyEquivalent: ""),
        NSMenuItem(title: "Preferences", action: #selector(preferences), keyEquivalent: "")
    ]
    
    public init(environmentObject: TouchBarMasterController) {
        self.tbMasterController = environmentObject
    }

    func start() {
        setupMenuIcon()
    }
}

// MARK: Setting up menu.
private extension MenuCreatorImpl {
    private func setupMenuIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: -1)

        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.title = "🌯"

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
        guard window == nil else { return }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 480),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Preference"
        window.titleVisibility = .hidden
        window.setFrameAutosaveName("Preference")
        window.contentView = NSHostingView(rootView: contentView.environmentObject(self.tbMasterController))
        window.makeKeyAndOrderFront(nil)
    }

    @objc
    func exit() {
        NSApplication.shared.terminate(nil)
    }
}
