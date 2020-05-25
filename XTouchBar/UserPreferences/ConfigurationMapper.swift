//
//  ConfigurationMapper.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 22/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation
#warning("Probably not needed? Touchbar private API handles this for us somehow.")
protocol ConfigurationMapper {
  func map(configuration: Configuration) -> Any?
}
