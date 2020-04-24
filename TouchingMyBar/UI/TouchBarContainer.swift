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
                Button(action: { MasterMind().perform(shortcut) }) {
                    Image(nsImage: shortcut.icon ?? NSImage(named: "Support")!)//swiftlint:disable:this force_unwrapping
                        .renderingMode(.original)
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BarElementWidth.small.rawValue, height: Constants.TouchBar.height, alignment: .center)
                }
                .buttonStyle(BarButtonStyle(color: shortcut.backgroundColor))
            }
        }
    }
}

fileprivate struct BarButtonStyle: ButtonStyle {

    private let color: Color

    init(color: Colors) {
        switch color {
        case .gray:
            self.color = Color(red: 0.3, green: 0.3, blue: 0.3)
        case .red:
            self.color = Color(red: 0.8, green: 0, blue: 0)
        case .green:
            self.color = Color(red: 0, green: 0.6, blue: 0)
        case .blue:
            self.color = Color(red: 0, green: 0.3, blue: 1)
        case .yellow:
            self.color = Color(red: 0.9, green: 0.6, blue: 0)
        case .purple:
            self.color = Color(red: 0.9, green: 0, blue: 0.6)
        }
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(color)
        )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(configuration.isPressed ? Color.white.opacity(0.5) : .clear)
        )
            .padding(.horizontal, 4)
    }
}

struct TouchBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TouchBarContainer()
    }
    
}
