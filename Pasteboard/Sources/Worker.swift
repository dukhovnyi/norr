//
//  Worker.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import Combine

final class Keeper {

    /// Defines the state of current keeper.
    ///
    var state: AnyPublisher<State, Never> {
        stateSubj.eraseToAnyPublisher()
    }

    let storage: Storage

    init(
        pasteboard: NSPasteboard = .general,
        storage: Storage = .inMemory()
    ) {
        self.listener = ChangeListener(pasteboard: pasteboard)
        self.pasteboard = pasteboard
        self.stateSubj = .init(.inactive)
        self.storage = storage
    }

    /// Initiates start listening pasteboard, stores paste if needed, etc.
    ///
    func start() {

        defer { stateSubj.send(.active) }

        listener.startObserving()

        listenerSubscription = listener.value
            .sink { [weak self] newPaste in
                self?.storage.save(newPaste)
            }
    }

    /// Stops listening pasteboard
    ///
    func stop() {

        defer { stateSubj.send(.inactive) }
        listener.stopObserving()
    }

    @objc func paste(_ index: Int) {

        guard let paste = storage.cache().first(where: { $0.id == index }) else {
            return
        }

        pasteboard.clearContents()
        paste.contents.forEach {
            pasteboard.setData($0.value, forType: $0.type)
        }
    }
    // MARK: - Private

    private let pasteboard: NSPasteboard
    private let stateSubj: CurrentValueSubject<State, Never>

    private let listener: ChangeListener
    private var listenerSubscription: AnyCancellable?
}

extension Keeper {

    enum State {
        case active, inactive
    }
}

struct Storage {

    enum Update {
        case insert(Paste)
    }

    var update: () -> AnyPublisher<Update, Never>

    var cache: () -> [Paste]
    var save: (Paste) -> Void
}

extension Storage {

    static func inMemory() -> Self {

        var cache = Set<Paste>()
        let updateSubj = PassthroughSubject<Update, Never>()

        return Storage(
            update: {
                updateSubj.eraseToAnyPublisher()
            },
            cache: {
                cache.sorted()
            },
            save: {
                cache.insert($0)
                updateSubj.send(.insert($0))
            }
        )
    }
}
