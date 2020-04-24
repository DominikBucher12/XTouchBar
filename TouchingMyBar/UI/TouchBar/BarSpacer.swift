//
//  BarSpacer.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 06/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import SwiftUI

struct BarSpacer: View {
    
    @Binding var size: Constants.BarElementWidth
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: self.size.rawValue, height: Constants.TouchBar.height)
    }
}
