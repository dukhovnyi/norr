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

//        let history: HistoryManaging
        let preferences: PreferencesManaging

        @Published var prefs: Preferences = .def

        init(
//            history: HistoryManaging,
            preferences: PreferencesManaging
        ) {
//            self.history = history
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
