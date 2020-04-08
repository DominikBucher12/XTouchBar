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
struct DummyPerformable: Performable {}

struct TouchBarContainer: View {
    
    @State private var dummyIcon       = "x"
    @State private var dummyColor      = Color.red
    @State private var dummySize       = Constants.BarElementWidth.small
    @State private var dummyAction     = { TouchBarPresenter.shared.hideXTouchBar() }
    
    @State private var alohomoraIcon   = "ALOHOMORA"
    @State private var alohomoraColor  = Color.green
    @State private var alohomoraSize   = Constants.BarElementWidth.big
    @State private var alohomoraAction = {
        #warning("TODO: Replace with real implementation")
        let dummy = DummyPerformable()
        let shortcut = Shortcut(key: .A, modifiers: [.command, .shift]) // Show code actions
        dummy.perform(shortcut)
    }
    
    var body: some View {
        HStack {
            BarButton(icon: $dummyIcon, color: $dummyColor, size: $dummySize, action: $dummyAction)
            BarSpacer(size: $dummySize)
            BarButton(icon: $alohomoraIcon, color: $alohomoraColor, size: $alohomoraSize, action: $alohomoraAction)
        }
    }
}

struct TouchBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TouchBarContainer()
    }
}
