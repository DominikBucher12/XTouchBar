//
//  Shortcut.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 08/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// Purest form of shortcut.
/// In real life, shortcut consists of some keys (like `cmd + a`, or `cmd + shift + o`)
/// In here, we divide the shortcut into actual pure keys (like letters, numbers, commas...)
/// and modifiers (The fancy keys like `cmd`, `control`, `shift`, `alt`)
class Shortcut: NSObject, Identifiable {
  
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
  let backgroundColor: Colors
  /// The shortcuts identifier. Pretty self-explanatory.
  let id: String
  /// Just simple key -> `a`, `y`, `,`, `=`, `+`, `/`
  let key: Key
  /// Set of Modifier(s), the more fancier: `cmd`, `shift`, `control`, `alt`, ???
  /// Set because it's fancy and doesn't contain duplicates
  let modifiers: Set<KeyModifier>
  /// Description used for Customization pallete used by touchbar. :)
  let itemDescription: String
  
  /// Why Swift cannot handle optional property in structs with default initializer? Very sad times.
  public init(
    iconData: Data? = nil,
    backgroundColor: Colors = .gray,
    id: String,
    key: Key,
    modifiers: Set<KeyModifier>,
    itemDescription: String
  ) {
    self.iconData = iconData
    self.backgroundColor = backgroundColor
    self.id = id
    self.key = key
    self.modifiers = modifiers
    self.itemDescription = itemDescription
  }
  
  // MARK: Decodable
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    iconData = try? values.decode(Data.self, forKey: .iconData)
    backgroundColor = try values.decode(Colors.self, forKey: .backgroundColor)
    id = try values.decode(String.self, forKey: .id)
    key = try values.decode(Key.self, forKey: .key)
    modifiers = try values.decode(Set<KeyModifier>.self, forKey: .modifiers)
    itemDescription = try values.decode(String.self, forKey: .itemDescription)
  }
  
  // MARK: Encodable
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(iconData, forKey: .iconData)
    try container.encode(backgroundColor, forKey: .backgroundColor)
    try container.encode(id, forKey: .id)
    try container.encode(key.rawValue, forKey: .key)
    try container.encode(modifiers, forKey: .modifiers)
    try container.encode(description, forKey: .itemDescription)
  }
  
  @objc
  public func runSelf() {
    MasterMind.perform(self)
  }
}

// MARK: - Codable

extension Shortcut: Codable {
  
  enum CodingKeys: String, CodingKey {
    case iconData
    case backgroundColor
    case id
    case key
    case modifiers
    case itemDescription
  }
}
