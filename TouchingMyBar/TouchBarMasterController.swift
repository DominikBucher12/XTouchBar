//
//  TouchBarMasterController.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 25/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Combine

final class TouchBarMasterController: ObservableObject {
    @Published var shortcuts: [Shortcut] = Configuration.default.shortcuts
}
