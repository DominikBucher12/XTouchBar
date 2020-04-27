//
//  TouchBarContainer.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import CoreGraphics
import SwiftUI

struct TouchBarContainer: View {
    @EnvironmentObject var controller: TouchBarMasterController
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: 2) {
                ForEach(controller.shortcuts) { shortcut in
                    BarButton(shortcut: shortcut)
                }
            }
        }
        .frame(width: Constants.TouchBar.youWishMaximumAppRegion, height: Constants.TouchBar.height)
    }
}

struct TouchBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TouchBarContainer()
    }
}
