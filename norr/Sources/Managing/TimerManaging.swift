//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Foundation

enum TimerManaging {

    typealias Interface = TimerManagingInterface
}

protocol TimerManagingInterface {

    func schedule(
        timeInterval: TimeInterval,
        repeats: Bool,
        _ action: @escaping () -> Void
    )

    func invalidate()
}

extension TimerManaging {

    final class Impl: Interface {

        func schedule(
            timeInterval: TimeInterval,
            repeats: Bool,
            _ action: @escaping () -> Void
        ) {

            timer?.invalidate()

            timer = Timer.scheduledTimer(
                withTimeInterval: timeInterval,
                repeats: repeats
            ) { timer in
                action()
            }
        }

        func invalidate() {

            timer?.invalidate()
            timer = nil
        }

        // MARK: - Private

        private var timer: Timer?
    }
}

extension TimerManaging {

    final class Mock: Interface {
        
        enum Call: Equatable {
            case schedule(TimeInterval, Bool)
            case invalidate
        }

        var m_calls = [Call]()
        var m_action: (() -> Void)?
        
        func m_emulateTimerExecution() {
            m_action?()
        }

        func schedule(
            timeInterval: TimeInterval,
            repeats: Bool,
            _ action: @escaping () -> Void
        ) {
            m_calls.append(.schedule(timeInterval, repeats))
            m_action = action
        }

        func invalidate() {
            m_action = nil
            m_calls.append(.invalidate)
        }
    }
}
