//
//  PreferencesUI.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 22/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import SwiftUI

struct TouchBar: View {
    @Binding var shortcuts: [Shortcut]
    @Binding var selectedShortcut: Shortcut
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.black)
                .frame(height: 40)
            
            HStack {
                ForEach(shortcuts) { shortcut in
                    Button(action: { self.selectedShortcut = shortcut }) {
                        Image(nsImage: shortcut.icon ?? NSImage(named: "Support")!)//swiftlint:disable:this force_unwrapping
                            .renderingMode(.original)
                            .resizable(resizingMode: .stretch)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BarElementWidth.small.rawValue, height: Constants.TouchBar.height, alignment: .center)
                    }
                    .buttonStyle(BarButtonStyle(color: shortcut.backgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(lineWidth: 3)
                            .foregroundColor(shortcut == self.selectedShortcut ? .white : .clear)
                            .frame(width: Constants.BarElementWidth.small.rawValue, height: Constants.TouchBar.height)
                    )
                }
            }
        }
    }
}

struct PreferencesUI: View {
    @EnvironmentObject var controller: TouchBarMasterController
    @State private var selectedShortcut: Shortcut = .addDocumentation
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: { self.controller.shortcuts.removeAll { $0.id == self.selectedShortcut.id } }) {
                Text("Remove shortcut")
            }
            TouchBar(shortcuts: $controller.shortcuts, selectedShortcut: $selectedShortcut)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PreferencesUI_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesUI()
    }
}
