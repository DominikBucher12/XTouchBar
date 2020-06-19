//
//  FunnyView.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 19/06/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

import Cocoa

class FunnyView: NSView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    #warning("Keep in mind this feature is still beta, when the TURBO MODE is fully working, will update the text")
    let label = NSTextField(string: "Xcode beta TURBO MODE is enabled. You can press the 🚀 to build even faster.")
    label.textColor = .red
    let button = NSButton(title: "🚀", target: nil, action: nil)

    let stack = NSStackView(views: [label, button])
    stack.orientation = .horizontal
    addSubview(stack)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
      stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
      stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
      stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
    ])
  }

  // gotta love available unavailable :D
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("You are one of the storyboard guys, ain't ya?")
  }
}
