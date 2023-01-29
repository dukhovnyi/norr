//
//  QuickStorage.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import Foundation

@propertyWrapper
struct QuickStorage<T: Codable> {

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
        userDefaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    // MARK: - Private

    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults

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
