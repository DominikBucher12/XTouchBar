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
    @State private var mediumButtonSize = Constants.BarElementWidth.medium
    @State private var openQuicklyShortcut = Shortcut.openQuickly

    @State private var addDocumentationShortcut = Shortcut.addDocumentation

    @State private var openFile = "Open"
    @State private var addDocumentation = "D"
    var body: some View {
        HStack {
            BarButton(icon: $openFile, size: $mediumButtonSize, shortcut: $openQuicklyShortcut)
            BarButton(icon: $addDocumentation, size: $mediumButtonSize, shortcut: $addDocumentationShortcut)
        }
    }
}

struct TouchBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TouchBarContainer()
    }
}
