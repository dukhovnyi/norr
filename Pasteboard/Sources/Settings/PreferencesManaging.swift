//
//  PreferencesManaging.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import Combine
import Foundation

struct PreferencesManaging {

    var preferences: () -> AnyPublisher<Preferences, Never>

    var update: (Preferences) -> Void
}

extension PreferencesManaging {

    static func live() -> Self {

        @QuickStorage(key: "settings", defaultValue: Preferences.def) var pref
        let value = CurrentValueSubject<Preferences, Never>(pref)

        return .init(
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
    ) -> Self {

        .init(
            preferences: { subj.eraseToAnyPublisher() },
            update: update
        )
    }
}
