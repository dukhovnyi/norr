//
//  Worker.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import Combine

final class Worker {

    let history: HistoryManaging
    let pasteboard: PasteboardManaging
    let preferences: PreferencesManaging

    /// Defines the state of current keeper.
    ///
    var state: AnyPublisher<State, Never> {
        stateSubj.eraseToAnyPublisher()
    }

    init(
        historyManaging: HistoryManaging,
        pasteboardManaging: PasteboardManaging,
        preferences: PreferencesManaging
    ) {
        self.history = historyManaging
        self.pasteboard = pasteboardManaging
        self.preferences = preferences
        self.stateSubj = .init(.inactive)
    }

    /// Initiates start listening pasteboard, stores paste if needed, etc.
    ///
    func start() {

        defer { stateSubj.send(.active) }

        pasteboard.start()
        subscriptions.pasteboard = pasteboard.value
            .sink { [weak self] newPaste in
                self?.history.save(newPaste)
            }
    }

    /// Stops listening pasteboard
    ///
    func stop() {

        pasteboard.stop()
        stateSubj.send(.inactive)
    }

    func use(paste: Paste) {
        pasteboard.apply(paste)
    }

    func clear() {
        history.clean()
    }

    // MARK: - Private

    private let stateSubj: CurrentValueSubject<State, Never>

    private var subscriptions: (pasteboard: AnyCancellable?, preferences: AnyCancellable?) = (nil, nil)
}

extension Worker {

    enum State {
        case active, inactive
    }
}
