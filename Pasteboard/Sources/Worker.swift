//
//  Worker.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import Combine

class Worker {

    let history = History()

    init(
        pasteboard: NSPasteboard = .general
    ) {
        self.pasteboard = pasteboard
        self.listener = ChangeListener(pasteboard: pasteboard)
    }
    
    func start() {

        defer { listener.startObserving() }

        listenerSubscription = listener.value.sink { [weak history] newItem in
            history?.store(newItem)
        }
    }

    func use(_ paste: Paste) {

        pasteboard.clearContents()
        paste.contents.forEach {
            pasteboard.setData($0.value, forType: $0.type)
        }
    }

    // MARK: - Private

    private let pasteboard: NSPasteboard
    private var listenerSubscription: AnyCancellable?
    private let listener: ChangeListener
}

class History {

    var value: AnyPublisher<[Paste], Never> {
        valuePublisher.eraseToAnyPublisher()
    }
    var cache = [Paste]()

    func store(_ newItem: Paste) {

        cache.append(newItem)
        valuePublisher.send(cache)
    }

    // MARK: - Private

    private let valuePublisher = PassthroughSubject<[Paste], Never>()
}
