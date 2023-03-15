//
//  PreferencesView.ViewModel.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import Combine
import Foundation

extension PreferencesView {

    final class ViewModel: ObservableObject {

        let formatter: NumberFormatter = {
            let f = NumberFormatter()
            f.minimum = 3
            f.maximum = 1_000
            return f
        }()
        let preferences: PreferencesManaging

        @Published var prefs: Preferences = .def

        init(
            preferences: PreferencesManaging
        ) {
            self.preferences = preferences
            self.subscription = preferences.preferences()
                .sink(receiveValue: { [weak self] newValue in
                    self?.prefs = newValue
                })
        }

        // MARK: - Private

        private var subscription: AnyCancellable?
    }
}
