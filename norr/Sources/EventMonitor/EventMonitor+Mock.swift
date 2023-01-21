//
// Copyright © 2024 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

extension EventMonitor {

    final class Mock: Interface {
        var publisher: AnyPublisher<Key, Never> {
            mock.eraseToAnyPublisher()
        }

        init(mock: PassthroughSubject<Key, Never> = .init()) {
            self.mock = mock
        }

        let mock: PassthroughSubject<Key, Never>
    }

}
