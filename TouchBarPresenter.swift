//
//  TouchBarPresenter.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//
import SwiftUI

class TouchBarPresenter: NSObject {

    static let shared = TouchBarPresenter()
    let touchBar = NSTouchBar()

    func clearUpTouchBar() {
        presentSystemModal(TouchBarPresenter.shared.touchBar, placement: 1, systemTrayItemIdentifier: .controlStripItem)
    }

    func hideXTouchBar() {
        minimizeSystemModal(TouchBarPresenter.shared.touchBar)
    }

    func makeButton() {
        let item = NSCustomTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: "HelloWorld"))
        item.view = NSHostingView(rootView: TouchBarContainer())

        TouchBarPresenter.shared.touchBar.defaultItemIdentifiers = [item.identifier]
        TouchBarPresenter.shared.touchBar.templateItems = [item]
    }

    private override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = []
    }
}
