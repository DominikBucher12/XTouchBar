//
//  TouchBarContainer.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import CoreGraphics
import SwiftUI

let tab       = 0x30
let space     = 0x31
let backslash = 0x32
let delete    = 0x33
let returnKey = 0x34

let probablyEscapeKey = 0x35
let shouldBeRightCommandButDoesntSeemToWork = 0x36
let shouldBeCommandButDoesntWork = 0x37


struct TouchBarContainer: View {

    @State private var dummyIcon       = "x"
    @State private var dummyColor      = Color.red
    @State private var dummySize       = Constants.BarElementWidth.small
    @State private var dummyAction     = { TouchBarPresenter.shared.hideXTouchBar() }

    @State private var alohomoraIcon   = "ALOHOMORA"
    @State private var alohomoraColor  = Color.green
    @State private var alohomoraSize   = Constants.BarElementWidth.big
    @State private var alohomoraAction = {

	 	let commandDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x37, keyDown: true)
	 	let hDown       = CGEvent(keyboardEventSource: nil, virtualKey: 0x04, keyDown: true)
	 	let hUp         = CGEvent(keyboardEventSource: nil, virtualKey: 0x04, keyDown: false)
	 	let commandUp   = CGEvent(keyboardEventSource: nil, virtualKey: 0x37, keyDown: false)

		commandDown!.post(tap: .cgAnnotatedSessionEventTap)
		hDown!.post(tap: .cgAnnotatedSessionEventTap)
		hUp!.post(tap: .cgAnnotatedSessionEventTap)
		commandUp!.post(tap: .cgAnnotatedSessionEventTap)

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
