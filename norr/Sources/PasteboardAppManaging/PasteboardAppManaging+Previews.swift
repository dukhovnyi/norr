//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

extension PasteboardAppManaging {

    final class Previews: Interface {

        var state: AnyPublisher<State, Never>

        var analyticsController: AnalyticsController.Interface
        var appExclusionController: AppExclusionController.Interface
        var historyController: HistoryManaging.Interface
        var pasteboard: PasteboardManaging.Interface

        init(
            state: CurrentValueSubject<State, Never> = .init(.initialization),
            analyticsController: AnalyticsController.Interface = AnalyticsController.Previews(),
            appExclusionController: AppExclusionController.Interface = AppExclusionController.Previews(),
            historyController: HistoryManaging.Interface = HistoryManaging.Previews(),
            pasteboard: PasteboardManaging.Interface = PasteboardManaging.Previews()
        ) {
            self.state = state.eraseToAnyPublisher()
            self.analyticsController = analyticsController
            self.appExclusionController = appExclusionController
            self.historyController = historyController
            self.pasteboard = pasteboard
        }

        func pause() {}
    }
}

