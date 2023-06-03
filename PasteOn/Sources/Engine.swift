//
//  Engine.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import Combine
import Foundation

final class Engine {

    let history: History
    let pasteboard: PasteboardManaging
    let excludeApps: ExcludeApps

    init(
        history: History,
        pasteboard: PasteboardManaging,
        excludeApps: ExcludeApps
    ) {
        self.history = history
        self.pasteboard = pasteboard
        self.excludeApps = excludeApps
    }

    func start() {

        cancellableSubscription = pasteboard.value
            .filter { [weak self] paste in
                if let self, let bundleId = paste.bundleId {
                    return !self.excludeApps.isExcluded(bundleId)
                }
                return true
            }
            .sink { [weak self] newItem in
                self?.history.append(newItem)
            }

        pasteboard.start()
    }

    func stop() {

        pasteboard.stop()
        cancellableSubscription = nil
    }

    // MARK: - Private

    private var cancellableSubscription: AnyCancellable?
}

extension Engine {
    static func previews() -> Engine {
        .init(
            history: .previews(),
            pasteboard: .mock(),
            excludeApps: .previews()
        )
    }
}
