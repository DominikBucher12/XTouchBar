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
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(Configuration.default.shortcuts) { shortcut in
                Button(action: { MasterMind.perform(shortcut) }) {
                    Image(nsImage: shortcut.icon ?? NSImage(named: "Support")!)//swiftlint:disable:this force_unwrapping
                        .renderingMode(.original)
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BarElementWidth.small.rawValue, height: Constants.TouchBar.height, alignment: .center)
                }
            }
        }
    }
}
struct TouchBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TouchBarContainer()
    }
}
