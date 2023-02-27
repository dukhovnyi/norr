//
//  PreferencesManaging.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import Combine
import Foundation

/// Defines mechanisms for cooperation with application configuration
///  including storing, fetching, etc.
///
class PreferencesManaging {

    /// Gets current preferences.
    ///
    var current: () -> Preferences

    /// Publisher that sends preferences as soon as it changed.
    /// Returns current value imidiately after subscribing.
    ///
    var preferences: () -> AnyPublisher<Preferences, Never>

    /// Updates preferences and store it.
    ///
    var update: (Preferences) -> Void

    init(
        current: @escaping () -> Preferences,
        preferences: @escaping () -> AnyPublisher<Preferences, Never>,
        update: @escaping (Preferences) -> Void
    ) {

        self.current = current
        self.preferences = preferences
        self.update = update
    }
}

extension PreferencesManaging {

    static func live() -> PreferencesManaging {

        @QuickStorage(key: "settings", defaultValue: Preferences.def) var pref

        let value = CurrentValueSubject<Preferences, Never>(pref)

        return .init(
            current: { value.value },
            preferences: { value.eraseToAnyPublisher() },
            update: { newValue in

                pref = newValue
                value.send(newValue)
            }
        )
    }
}

extension PreferencesManaging {

    static func mock(
        subj: CurrentValueSubject<Preferences, Never> = .init(.def),
        update: @escaping (Preferences) -> Void = { _ in }
    ) -> PreferencesManaging {

        .init(
            current: { subj.value },
            preferences: { subj.eraseToAnyPublisher() },
            update: update
        )
    }
}
