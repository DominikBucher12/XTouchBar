//
//  ConfigurationStore.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 21/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// Interface for Storage.
/// It has 2 basic functions, load and store the configuration.
/// Nothing else matters ♫
protocol ConfigrationStorage {
    func store(configuration: Configuration) throws
    func loadConfiguration(with name: String) throws -> Configuration
}

/// Implementation. FTW
class ConfigurationStorageImpl: ConfigrationStorage {
    private enum Errors: Error {
        case couldntFetchEncodedData
        case couldntEncodeConfiguration(configuration: Configuration)
    }

    func store(configuration: Configuration) throws {
        // Finally, I am not writing Showmax code, so my codestyle is fresh with ```{ command(); anotherOne() }``` Oneliners, FTW!! 🤟🏻
        // swiftlint:disable:next statement_position
        do { let data = try JSONEncoder().encode(configuration); UserDefaults.standard.set(data, forKey: configuration.name) }
        catch { throw Errors.couldntEncodeConfiguration(configuration: configuration) }
    }

    func loadConfiguration(with name: String) throws -> Configuration {
        guard let encodedData = UserDefaults.standard.data(forKey: name) else { throw Errors.couldntFetchEncodedData }
        return try! JSONDecoder().decode(Configuration.self, from: encodedData) // swiftlint:disable:this force_try
    }
}
