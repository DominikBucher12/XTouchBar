//
//  Shortcut.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 08/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// Purest form of shortcut.
/// In real life, shortcut consists of some keys (like `cmd + a`, or `cmd + shift + o`)
/// In here, we divide the shortcut into actual pure keys (like letters, numbers, commas...)
/// and modifiers (The fancy keys like `cmd`, `control`, `shift`, `alt`)
class Shortcut: NSObject, Identifiable {

  /// Kind of the button,
  /// Should probably rename shortcut to something else,
  /// but this Sprint has to be done by 6/13/2020 0:00 🏃‍♂️
  enum Kind {
    case realShortcut
    case button(action: () -> Void)
  }

  /// Icon for the shortcut to present on touchbar.
  /// is being made from the data of the image
  var icon: NSImage? {
    guard let data = self.iconData else { return nil }
    let image = NSImage(data: data)
    image?.resizingMode = .stretch
    return image
  }
  
  /// We want to store the icon inside `UserDefaults`, that's why we use this "hack"
  /// to store and fetch data of the image.
  private let iconData: Data?
  /// Background color of the button in the TouchBar.
  /// Default is gray.
  let bezelColor: NSColor?
  /// The shortcuts identifier. Pretty self-explanatory.
  let id: String
  /// Just simple key -> `a`, `y`, `,`, `=`, `+`, `/`
  let key: Key
  /// Set of Modifier(s), the more fancier: `cmd`, `shift`, `control`, `alt`, ???
  /// Set because it's fancy and doesn't contain duplicates
  let modifiers: Set<KeyModifier>
  /// Description used for Customization pallete used by touchbar. :)
  let itemDescription: String

  /// Kind of shortcut, if it's really shortcut or if it makes something else
  let kind: Kind

  /// Why Swift cannot handle optional property in structs with default initializer? Very sad times.
  public init(
    iconData: Data? = nil,
    bezelColor: NSColor? = nil,
    id: String,
    key: Key,
    modifiers: Set<KeyModifier>,
    itemDescription: String,
    kind: Kind = .realShortcut
  ) {
    self.iconData = iconData
    self.bezelColor = bezelColor
    self.id = id
    self.key = key
    self.modifiers = modifiers
    self.itemDescription = itemDescription
    self.kind = kind
  }
  @objc
  public func runSelf() {
    switch kind {
    case .realShortcut:
      MasterMind.perform(self)
    case .button(let action):
      action()
    }
  }
}
