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
    @Binding var selectedShortcutID: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.black)
                .frame(height: 40)
            
            HStack {
                ForEach(shortcuts) { shortcut in
                    Button(action: { self.selectedShortcutID = shortcut.id }) {
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
                            .foregroundColor(shortcut.id == self.selectedShortcutID ? .white : .clear)
                            .frame(width: Constants.BarElementWidth.small.rawValue, height: Constants.TouchBar.height)
                    )
                }
            }
        }
    }
}

struct PreferencesUI: View {
    @State private var shortcuts: [Shortcut] = Configuration.krossConfig.shortcuts
    @State private var selectedShortcutID = ""
    // This is nasty, just using hacks to prototype UI
    @State private var shortcutsToPickFrom = Configuration.krossConfig.shortcuts
    @State private var shortcutToAddIndex = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Picker("Shortcuts:", selection: $shortcutToAddIndex) {
                    ForEach(0..<shortcutsToPickFrom.count) {
                        Text("\(self.shortcutsToPickFrom[$0].id)")
                    }
                }
                .frame(width: 300)
                
                Button(action: { self.shortcuts.append(self.shortcutsToPickFrom[self.shortcutToAddIndex]) }) {
                    Text("Add")
                }
            }
            
            Button(action: {
                for i in 0..<self.shortcuts.count {
                    if self.shortcuts[i].id == self.selectedShortcutID {
                        self.shortcuts.remove(at: i)
                        self.selectedShortcutID = ""
                        break
                    } else {
                        continue // FIXME: SwiftLint complains
                    }
                }
            }) {
                Text("Remove shortcut")
            }
            TouchBar(shortcuts: $shortcuts, selectedShortcutID: $selectedShortcutID)
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
