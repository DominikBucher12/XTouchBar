//
//  ConfigurationStore.swift
//  TouchingMyBar
//
//  Created by Dominik Bucher on 21/04/2020.
//  Copyright © 2020 Dominik Bucher. All rights reserved.
//

protocol ConfigrationStorage {
    func store(configuration: Configuration)
    func loadConfiguration(with name: String) -> Configuration
}

/// Implementation. FTW
class ConfigurationStorageImpl: ConfigrationStorage {
    func store(configuration: Configuration) {
        UserDefaults.standard.setStruct(configuration, forKey: configuration.name)
    }

    func loadConfiguration(with name: String) -> Configuration {
        return UserDefaults.standard.object(forKey: name) as! Configuration
    }
}
