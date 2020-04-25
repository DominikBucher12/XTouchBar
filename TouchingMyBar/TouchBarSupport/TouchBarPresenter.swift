//
//  TouchBarPresenter.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//
import SwiftUI

class TouchBarPresenter: NSObject, NSTouchBarDelegate {

    static let shared = TouchBarPresenter()
    let touchBar = NSTouchBar()
    let tbMasterController = TouchBarMasterController()

    func clearUpTouchBar() {
        // Note, if you want the touchbar to cover just part of the screen and not hide the right control strip,
        // Use the other implementation which has the dafault parameter of `placement: 0` :)
        presentSystemModal(TouchBarPresenter.shared.touchBar, placement: 0, systemTrayItemIdentifier: .controlStripItem)
    }

    func hideXTouchBar() {
        minimizeSystemModal(TouchBarPresenter.shared.touchBar)
    }

    func makeXTouchBar() {
        let item = NSCustomTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: "XTouchBar"))
        item.view = NSHostingView(rootView: TouchBarContainer().environmentObject(tbMasterController))

        TouchBarPresenter.shared.touchBar.defaultItemIdentifiers = [item.identifier]
        TouchBarPresenter.shared.touchBar.templateItems = [item]
    }

    private override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = []
    }
}
