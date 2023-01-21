//
// Copyright © 2024 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

protocol EventMonitorInterface {
    var publisher: AnyPublisher<EventMonitor.Key, Never> { get }
}
