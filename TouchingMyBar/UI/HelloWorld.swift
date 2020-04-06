//
//  HelloWorld.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 02/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import SwiftUI

struct HelloWorld: View {

	@State private var backgroundColor = Color.red
	@State private var previousColor = Color.red

	private let colors: [Color] = [.red, .orange, .green, .blue, .yellow]

    var body: some View {
        Text("Jak to sviští? 😎")
            .frame(width: Constants.BarElementWidth.big.rawValue, height: Constants.TouchBar.height, alignment: .center)
			.foregroundColor(.white)
			.shadow(color: .black, radius: 2, x: 0, y: 0)
			.shadow(color: .black, radius: 2, x: 0, y: 0)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.foregroundColor(backgroundColor)
			)
			.onTapGesture {
                // This is probably how it's done
                let preferenceSet = IDEKeyBindingPreferenceSet()//(name: "XCode usper preference set", dataURL: URL(fileURLWithPath: ""))
                let bindings = preferenceSet.allKeyBindings as! [IDETextKeyBinding]
                let magicBinding = bindings.first { $0.title == "My Magic Key Binding" }
                
				var newColor = self.colors.randomElement()!

				while newColor == self.previousColor {
					newColor = self.colors.randomElement()!
				}

				self.previousColor = newColor
				self.backgroundColor = newColor
		}
    }
}
