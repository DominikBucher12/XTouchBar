//
//  ConfigurationMapper.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 22/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Foundation
protocol ConfigurationMapper {
  func map(configuration: Configuration) -> Any?
}
