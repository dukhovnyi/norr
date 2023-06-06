//
//  UserDefaults.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 02.06.2023.
//

import Foundation

@propertyWrapper
struct UserDefaults<T: Codable> {

    var wrappedValue: T {
        get {
            get()
        }

        set {
            set(newValue)
        }
    }

    init(
        key: String,
        defaultValue: T,
        userDefaults: Foundation.UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    // MARK: - Private

    private let key: String
    private let defaultValue: T
    private let userDefaults: Foundation.UserDefaults

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func get() -> T {

        guard let data = userDefaults.data(forKey: key) else { return defaultValue }
        return (try? decoder.decode(T.self, from: data)) ?? defaultValue
    }

    private func set(_ newValue: T) {

        let newData = try? encoder.encode(newValue)
        userDefaults.set(newData, forKey: key)
    }
}
