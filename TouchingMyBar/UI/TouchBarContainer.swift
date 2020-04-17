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
    @State private var unselectedButtonColor = Colors.buttonUnselected
    @State private var mediumButtonSize = Constants.BarElementWidth.medium
    @State private var openFileShortcut = Shortcut.openFileQuickly
    @State private var addDocsShortcut = Shortcut.addDocumentation

    @State private var openFile = "Open"
    @State private var addDocs  = "///"
    var body: some View {
        HStack {
            BarButton(icon: $openFile, color: $unselectedButtonColor, size: $mediumButtonSize, shortcut: $openFileShortcut)
            BarButton(icon: $addDocs, color: $unselectedButtonColor, size: $mediumButtonSize, shortcut: $addDocsShortcut)
        }
    }
}

struct TouchBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TouchBarContainer()
    }
}
