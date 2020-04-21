//
//  MenuCreator.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 22/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation

protocol MenuCreator {
    func start()
}

class MenuCreatorImpl: MenuCreator {
    private var appMenu: NSMenu! // swiftlint:disable:this implicitly_unwrapped_optional
    private var statusItem: NSStatusItem! // swiftlint:disable:this implicitly_unwrapped_optional
    private let menuItems: [NSMenuItem] = [
        NSMenuItem(title: "Exit application", action: #selector(exit), keyEquivalent: ""),
        NSMenuItem(title: "About", action: #selector(about), keyEquivalent: ""),
        NSMenuItem(title: "Preferences", action: #selector(preferences), keyEquivalent: "")
    ]
    
    func start() {
        createMenuItems()
        setupMenuIcon()
    }
}

// MARK: Setting up menu.
private extension MenuCreatorImpl {
    private func setupMenuIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: -1)

         guard let button = statusItem?.button else {
             NSApp.terminate(nil)
             return
         }

         button.title = "XTouchBar"
         button.target = self
         button.action = #selector(displayMenu)
        button.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
    }

    @objc
    private func displayMenu() {
        guard let button = statusItem?.button else { return }
        let x = button.frame.origin.x
        let y = button.frame.origin.y - 5

        guard let location = button.superview?.convert(NSPoint(x: x, y: y), to: nil),
              let niceWindow = button.window,
              let appMenu = appMenu,
              let event = NSEvent.mouseEvent(
                   with: .leftMouseUp,
                   location: location,
                   modifierFlags: NSEvent.ModifierFlags(rawValue: 0),
                   timestamp: 0,
                   windowNumber: niceWindow.windowNumber,
                   context: niceWindow.graphicsContext,
                   eventNumber: 0,
                   clickCount: 1,
                   pressure: 0
               )
        else { return }

        NSMenu.popUpContextMenu(appMenu, with: event, for: button)
    }

    private func createMenuItems() {
        let menu = NSMenu(title: "XTouchBar")

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
        // Show Preferences and show
    }

    @objc
    func exit() {
        NSApplication.shared.terminate(nil)
    }
}
