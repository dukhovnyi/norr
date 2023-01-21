//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Foundation

enum PasteboardAppManaging {
    typealias Interface = _PasteboardAppManagingInterface

    enum State {
        case initialization, ready
    }
}

import Combine

protocol _PasteboardAppManagingInterface {

    var state: AnyPublisher<PasteboardAppManaging.State, Never> { get }

    var analyticsController: AnalyticsController.Interface { get }
    var appExclusionController: AppExclusionController.Interface { get }
    var historyController: HistoryManaging.Interface { get }
    var pasteboard: PasteboardManaging.Interface { get }
}
