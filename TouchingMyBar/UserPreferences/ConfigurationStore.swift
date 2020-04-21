//
//  ConfigurationStore.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 21/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

enum DecodingError: Error {
    case couldntFetchEncodedData
    case couldntEncodeConfiguration(configuration: Configuration)
}

protocol ConfigrationStorage {
    func store(configuration: Configuration) throws
    func loadConfiguration(with name: String) throws -> Configuration
}

/// Implementation. FTW
class ConfigurationStorageImpl: ConfigrationStorage {
    func store(configuration: Configuration) throws {
        // Finally, I am not writing Showmax code, so my codestyle is fresh with ```{ command(); anotherOne() }``` Oneliners, FTW!! 🤟🏻
        // swiftlint:disable:next statement_position
        do { let data = try JSONEncoder().encode(configuration); UserDefaults.standard.set(data, forKey: configuration.name) }
        catch { throw DecodingError.couldntEncodeConfiguration(configuration: configuration) }
    }

    func loadConfiguration(with name: String) throws -> Configuration {
        guard let encodedData = UserDefaults.standard.data(forKey: name) else { throw DecodingError.couldntFetchEncodedData }
        return try! JSONDecoder().decode(Configuration.self, from: encodedData) // swiftlint:disable:this force_try
    }
}
