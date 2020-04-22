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
                    .foregroundColor(configuration.isPressed ? Colors.buttonSelected : Colors.buttonUnselected)
                )
                .padding(.horizontal, 4)
    }
}

struct BarButton: View {
    @Binding var color: Color
    @Binding var size: Constants.BarElementWidth
    @Binding var shortcut: Shortcut

    var body: some View {
        Button(action: { MasterMind().perform(self.shortcut) }) {
            Text(shortcut.id)
                .font(.callout)
                .frame(width: self.size.rawValue, height: Constants.TouchBar.height, alignment: .center)
        }
        .buttonStyle(CustomButtonStyle(color: self.color))
    }
}
