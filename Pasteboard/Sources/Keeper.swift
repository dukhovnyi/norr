//
//  Keeper.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import Combine

final class Keeper {

    let preferencesManaging: PreferencesManaging
    let history: HistoryManaging

    /// Defines the state of current keeper.
    ///
    var state: AnyPublisher<State, Never> {
        stateSubj.eraseToAnyPublisher()
    }

    init(
        pasteboard: NSPasteboard,
        preferencesManaging: PreferencesManaging,
        storage: HistoryManaging
    ) {
        self.listener = PasteboardChangeListener(pasteboard: pasteboard)
        self.pasteboard = pasteboard
        self.preferencesManaging = preferencesManaging
        self.stateSubj = .init(.inactive)
        self.history = storage
    }

    /// Initiates start listening pasteboard, stores paste if needed, etc.
    ///
    func start() {

        defer { stateSubj.send(.active) }

        listener.startObserving()

        listenerSubscription = listener.value
            .sink { [weak self] newPaste in
                self?.history.save(newPaste)
            }
    }

    /// Stops listening pasteboard
    ///
    func stop() {

        defer { stateSubj.send(.inactive) }
        listener.stopObserving()
    }

    @objc func paste(_ index: Int) {

        guard let paste = history.cache().first(where: { $0.id == index }) else {
            return
        }

        use(paste: paste)
    }

    func use(paste: Paste) {

        pasteboard.clearContents()
        paste.contents.forEach {
            pasteboard.setData($0.value, forType: $0.type)
        }
    }

    // MARK: - Private

    private let pasteboard: NSPasteboard
    private let stateSubj: CurrentValueSubject<State, Never>

    private let listener: PasteboardChangeListener
    private var listenerSubscription: AnyCancellable?
}

extension Keeper {

    enum State {
        case active, inactive
    }
}
