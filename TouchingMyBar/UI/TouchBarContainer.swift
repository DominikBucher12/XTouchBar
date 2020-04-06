//
//  TouchBarContainer.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import SwiftUI

struct TouchBarContainer: View {
    
    @State private var dummyIcon = "x"
    @State private var dummyColor = Color.green
    @State private var dummySize = Constants.BarElementWidth.small
    @State private var dummyAction = { TouchBarController.shared.hideXTouchBar() }
    
    var body: some View {
        HStack {
            BarButton(icon: $dummyIcon, color: $dummyColor, size: $dummySize, action: $dummyAction)
            BarSpacer(size: $dummySize)
            HelloWorld()
            BarButton(icon: $dummyIcon, color: $dummyColor, size: $dummySize, action: $dummyAction)
        }
    }
}

struct TouchBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TouchBarContainer()
    }
}
