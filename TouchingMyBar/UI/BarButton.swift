//
//  BarButton.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import SwiftUI

fileprivate struct CustomButtonStyle: ButtonStyle {

    private let color: Color

    init(color: Color) {
        self.color = color
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(configuration.isPressed ? Colors.buttonUnselected : Colors.buttonSelected)
                )
                .padding(.horizontal, 2)
    }
}

struct BarButton: View {

//     @Binding var identifier: String
    #warning("swap for real icons when we have them")
    @Binding var icon: String
    @Binding var size: Constants.BarElementWidth
    @Binding var shortcut: Shortcut

    var body: some View {
        Button(
            action: {
                IDECommandManager.initialize()
                IDECommandManager.cacheCommandDefinitionsAndHandlers()
                let commands = IDEApplicationCommands()
                commands.exposedBindings
            /*try? MasterMind().perform(self.shortcut)*/

            }
        ) {
            Text(self.icon)
                .font(.callout)
                .frame(width: self.size.rawValue, height: Constants.TouchBar.height, alignment: .center)
        }
    }
}
