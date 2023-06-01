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

    init(
        history: History,
        pasteboard: PasteboardManaging
    ) {
        self.history = history
        self.pasteboard = pasteboard
    }

    func start() {

        cancellableSubscription = pasteboard.value
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
