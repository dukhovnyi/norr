//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

extension PasteboardAppManaging {

    final class Impl: Interface {

        let analyticsController: AnalyticsController.Interface
        let appExclusionController: AppExclusionController.Interface
        let pasteboard: PasteboardManaging.Interface

        var state: AnyPublisher<State, Never> { stateSubj.eraseToAnyPublisher() }

        var historyController: HistoryManaging.Interface {
            _historyController
        }

        init(
            analyticsController: AnalyticsController.Interface,
            appExclusionController: AppExclusionController.Interface,
            historyController: HistoryManaging.Interface,
            pasteboard: PasteboardManaging.Interface
        ) {
            self.analyticsController = analyticsController
            self.appExclusionController = appExclusionController
            self._historyController = historyController
            self.pasteboard = pasteboard

            setup()
        }

        // MARK: - Private

        private let stateSubj = CurrentValueSubject<State, Never>(.initialization)

        private var _historyController: HistoryManaging.Interface
        private var cancellables = Set<AnyCancellable>()

        private var appExclusions = [String]()

        private func setup() {

            defer {
                pasteboard.start()
            }

            appExclusionController.apps
                .sink { [weak self] appExclusions in
                    self?.appExclusions = appExclusions
                }
                .store(in: &cancellables)

            pasteboard.value
                .sink { [weak self] newPasteboardItem in

                    guard let self else { return }

                    if let bundleId = newPasteboardItem.bundleId,
                       self.appExclusions.contains(bundleId) {
                        return
                    }

                    self.historyController.store(newPasteboardItem)
                }
                .store(in: &cancellables)
        }
    }

}
