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
	private let touchBarElementMaxHeight: CGFloat = 30
	
    var body: some View {
        Text("Jak to sviští? 😎")
			.frame(width: 400, height: touchBarElementMaxHeight, alignment: .center)
			.foregroundColor(.white)
			.shadow(color: .black, radius: 2, x: 0, y: 0)
			.shadow(color: .black, radius: 2, x: 0, y: 0)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.foregroundColor(backgroundColor)
			)
			.onTapGesture {
				var newColor = self.colors.randomElement()!
				
				while newColor == self.previousColor {
					newColor = self.colors.randomElement()!
				}
				
				self.previousColor = newColor
				self.backgroundColor = newColor
		}
    }
}

struct HelloWorld_Previews: PreviewProvider {
    static var previews: some View {
        HelloWorld()
    }
}
