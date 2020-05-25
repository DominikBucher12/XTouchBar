//
//  ConfigurationStore.swift
//  XTouchBar
//
//  Created by Dominik Bucher on 21/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

/// Interface for Storage.
/// It has 2 basic functions, load and store the configuration.
/// I guess no documentation to this is needed :)
/// Nothing else matters ♫
#warning("Probably not needed? Touchbar private API handles this for us somehow.")
protocol ConfigurationStorage {
  func store(configuration: Configuration) throws
  func loadConfiguration(with name: String) throws -> Configuration
}

/// Implementation. FTW
class ConfigurationStorageImpl: ConfigurationStorage {
  private enum Errors: Error {
    case fetchEncodedDataFailure
    case encodeConfigurationFailure(configuration: Configuration)
    case decodeDataFailure
  }
  
  func store(configuration: Configuration) throws {
    // swiftlint:disable:next statement_position
    do { let data = try JSONEncoder().encode(configuration); UserDefaults.standard.set(data, forKey: configuration.name) }
    catch { throw Errors.encodeConfigurationFailure(configuration: configuration) }
  }
  
  func loadConfiguration(with name: String) throws -> Configuration {
    guard let encodedData = UserDefaults.standard.data(forKey: name) else { throw Errors.fetchEncodedDataFailure }
    do { return try JSONDecoder().decode(Configuration.self, from: encodedData) } catch { throw Errors.decodeDataFailure }
  }
}
