//
//  TouchBarContainer.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import CoreGraphics
import SwiftUI

#warning("TODO: Remove ASAP - just here for testing.")
struct DummyPerformable: KeyPresser { }

struct TouchBarContainer: View {

    @State private var dummyIcon       = "esc"
    @State private var dummyColor      = Color.white.opacity(0.2)
    @State private var dummySize       = Constants.BarElementWidth.small
    @State private var dummyAction     = { TouchBarPresenter.shared.hideXTouchBar() }

    @State private var alohomoraIcon   = "///"
    @State private var alohomoraColor  = Colors.buttonUnselected
    @State private var alohomoraSize   = Constants.BarElementWidth.medium
    @State private var alohomoraAction = {
        #warning("TODO: Replace with real implementation")
        let dummy = DummyPerformable()
        let shortcut = Shortcut(id: "BOGUS_ID", key: .D, modifiers: [.command, .shift, .control])
        dummy.perform(shortcut)
        #warning("JUST HERE FOR TESTING!!! Handle the error properly!!!")
        try! PListProcessor.process()
    }

    @State private var openFile = "Open"
    @State private var shortcutAction = { DummyPerformable().perform(Shortcut.openFileQuickly) }
    var body: some View {
        HStack {
            BarButton(icon: $dummyIcon, color: $dummyColor, size: $dummySize, action: $dummyAction)
            BarSpacer(size: $dummySize)
            BarButton(icon: $alohomoraIcon, color: $alohomoraColor, size: $alohomoraSize, action: $alohomoraAction)
            BarButton(icon: $openFile, color: $alohomoraColor, size: $alohomoraSize, action: $shortcutAction )
        }
    }
}

struct TouchBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TouchBarContainer()
    }
}
