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
    private(set) var history: HistoryManaging

    /// Defines the state of current keeper.
    ///
    var state: AnyPublisher<State, Never> {
        stateSubj.eraseToAnyPublisher()
    }

    init(
        pasteboard: NSPasteboard,
        preferencesManaging: PreferencesManaging
    ) {
        self.listener = PasteboardChangeListener(pasteboard: pasteboard)
        self.pasteboard = pasteboard
        self.preferencesManaging = preferencesManaging
        self.stateSubj = .init(.inactive)
        self.history = preferencesManaging.current().wipeHistoryOnClose
                ? .inMemory(preferencesManaging: preferencesManaging)
                : .coreData(preferencesManaging: preferencesManaging)

        self.preferencesSubscription = preferencesManaging.preferences()
            .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: true)
            .removeDuplicates()
            .sink { [weak self] preferences in

                guard let self else { return }

                if preferences.wipeHistoryOnClose {
                    self.history = .inMemory(preferencesManaging: preferencesManaging)
                } else {
                    self.history = .coreData(preferencesManaging: preferencesManaging)
                }
            }
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
    private var preferencesSubscription: AnyCancellable?
}

extension Keeper {

    enum State {
        case active, inactive
    }
}
