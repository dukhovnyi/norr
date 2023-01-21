//
// Copyright © 2024 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import Carbon
import Combine
import Foundation

extension EventMonitor {

    final class Impl: Interface {

        var publisher: AnyPublisher<EventMonitor.Key, Never> {
            subject.eraseToAnyPublisher()
        }

        init() {
            self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak subject] event in
                subject?.send(.init(rawValue: event.keyCode))
                return event
            }
        }

        deinit {
            if let eventMonitor {
                NSEvent.removeMonitor(eventMonitor)
            }
        }

        // MARK: - Private

        private let subject = PassthroughSubject<Key, Never>()
        private var eventMonitor: Any?
    }

}
