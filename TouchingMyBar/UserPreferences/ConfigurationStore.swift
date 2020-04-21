//
//  ConfigurationStore.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 21/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

enum DecodingError: Error {
    case couldntFetchEncodedData
    case moreThanOneKeyBindingsFileFound
}

protocol ConfigrationStorage {
    func store(configuration: Configuration)
    func loadConfiguration(with name: String) throws -> Configuration
}

/// Implementation. FTW
class ConfigurationStorageImpl: ConfigrationStorage {
    func store(configuration: Configuration) {
        let data = try? JSONEncoder().encode(configuration)
        UserDefaults.standard.set(data, forKey: configuration.name)
    }

    func loadConfiguration(with name: String) throws -> Configuration {
        guard let encodedData = UserDefaults.standard.data(forKey: name) else { throw DecodingError.couldntFetchEncodedData }

        return try! JSONDecoder().decode(Configuration.self, from: encodedData) // swiftlint:disable:this force_try
    }
}
//
//
//extension UserDefaults {
//    open func setStruct<T: Codable>(_ value: T?, forKey defaultName: String){
//        let data = try? JSONEncoder().encode(value)
//        set(data, forKey: defaultName)
//    }
//
//    open func structData<T>(_ type: T.Type, forKey defaultName: String) -> T? where T : Decodable {
//        guard let encodedData = data(forKey: defaultName) else {
//            return nil
//        }
//
//        return try! JSONDecoder().decode(type, from: encodedData)
//    }
//
//    open func setStructArray<T: Codable>(_ value: [T], forKey defaultName: String){
//        let data = value.map { try? JSONEncoder().encode($0) }
//
//        set(data, forKey: defaultName)
//    }
//
//    open func structArrayData<T>(_ type: T.Type, forKey defaultName: String) -> [T] where T : Decodable {
//        guard let encodedData = array(forKey: defaultName) as? [Data] else {
//            return []
//        }
//
//        return encodedData.map { try! JSONDecoder().decode(type, from: $0) }
//    }
//}
