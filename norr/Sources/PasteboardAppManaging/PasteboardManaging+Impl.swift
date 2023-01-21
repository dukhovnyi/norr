//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

extension PasteboardManaging {

    final class Impl: Interface {

        var value: AnyPublisher<Paste, Never> {
            valueSubj.eraseToAnyPublisher()
        }

        init(
            pasteboard: PasteboardInstance.Interface,
            dependency: PasteboardManaging.Dependency,
            timer: TimerManaging.Interface,
            updateInterval: TimeInterval
        ) {
            self.pasteboard = pasteboard
            self.dependency = dependency
            self.timer = timer
            self.updateInterval = updateInterval

            self.changeCount = Int.min
        }

        func start() {

            startTimer()
        }
        
        func stop() {
            
            stopTimer()
        }
        
        func setPasteboardItem(to newValue: Paste) {

            pasteboard.apply(paste: newValue)
        }
        
        func getCurrentPasteboardItem() -> Paste? {

            getPasteboardItems()
        }

        // MARK: - Private

        private let valueSubj = PassthroughSubject<Paste, Never>()

        private let pasteboard: PasteboardInstance.Interface
        private let dependency: PasteboardManaging.Dependency
        private let timer: TimerManaging.Interface
        private let updateInterval: TimeInterval

        private var changeCount: Int

        private func stopTimer() {
            
            timer.invalidate()
        }

        private func startTimer() {

            stopTimer()

            timer.schedule(
                timeInterval: updateInterval,
                repeats: true
            ) { [weak self] in

                guard let self else { return }
                guard changeCount != self.pasteboard.changeCount else {
                    return
                }
                self.changeCount = self.pasteboard.changeCount

                guard let pasteItem = self.getPasteboardItems() else { return }

                valueSubj.send(pasteItem)
            }
        }

        private func getPasteboardItems() -> Paste? {
            // pasteboard items are empty, nothing to get
            guard let contents = pasteboard.pasteboardItems, !contents.isEmpty else {
                return nil
            }

            let appBundleId = dependency.frontmostApplication?.bundleIdentifier
            let item = Paste(
                id: dependency.createId(),
                changeCount: changeCount,
                createdAt: dependency.now(),
                pasteboardItems: contents,
                bundleId: appBundleId
            )

            return item
        }
    }
}

extension PasteboardManaging {

    final class Previews: Interface {

        enum Call: Equatable {
            case start
            case stop
            case setPassteboardItem(Paste)
            case getCurrentPasteboardItem
        }

        var m_calls = [Call]()

        var value: AnyPublisher<Paste, Never>
        
        init(valueSubj: PassthroughSubject<Paste, Never> = .init()) {
            self.value = valueSubj.eraseToAnyPublisher()
        }

        func start() {
            m_calls.append(.start)
        }

        func stop() {
            m_calls.append(.stop)
        }

        func setPasteboardItem(to newValue: Paste) {
            m_calls.append(.setPassteboardItem(newValue))
        }

        func getCurrentPasteboardItem() -> Paste? {
            m_calls.append(.getCurrentPasteboardItem)
            return nil
        }
    }
}
