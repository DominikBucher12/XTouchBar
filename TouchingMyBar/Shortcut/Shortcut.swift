//
//  Shortcut.swift
//  TouchingMyBar
//
//  Created by Jan Kříž on 08/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// Purest form of shortcut.
/// In real life, shortcut consists of some keys (like `cmd + a`, or `cmd + shift + o`)
/// In here, we divide the shortcut into actual pure keys (like letters, numbers, commas...)
/// and modifiers (The fancy keys like `cmd`, `control`, `shift`, `alt`)
struct Shortcut {

    /// Icon for the shortcut to present on touchbar.
    lazy var icon: NSImage? = {
        guard let data = self.iconData else { return nil }
        return NSImage(data: data)
    }()

    private let iconData: Data?
    /// The shortcuts identifier. Pretty self-explanatory.
    let id: String
    /// Just simple key -> `a`, `y`, `,`, `=`, `+`, `/`
    let key: Key
    /// Set of Modifier(s), the more fancier: `cmd`, `shift`, `control`, `alt`, ???
    /// Set because it's fancy and doesn't contain duplicates
    let modifiers: Set<KeyModifier>

    /// Why Swift cannot handle optional property in structs with default initializer? Very sad times.
    public init(iconData: Data? = nil, id: String, key: Key, modifiers: Set<KeyModifier>) {
        self.iconData = iconData
        self.id = id
        self.key = key
        self.modifiers = modifiers
    }

}

extension Shortcut: Codable {

    enum CodingKeys: String, CodingKey {
        case iconData
        case id
        case key
        case modifiers
    }

    // MARK: Decodable

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        iconData = try values.decode(Data.self, forKey: .iconData)
        id = try values.decode(String.self, forKey: .id)
        key = try values.decode(Key.self, forKey: .key)
        modifiers = try values.decode(Set<KeyModifier>.self, forKey: .modifiers)
    }

    // MARK: Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(iconData, forKey: .iconData)
        try container.encode(id, forKey: .id)
        try container.encode(key.rawValue, forKey: .key)
        try container.encode(modifiers, forKey: .modifiers)
    }
}
