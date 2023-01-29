//
//  History.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import Combine
import Foundation

struct HistoryManaging {

    enum Update {
        case insert(Paste)
        case removeAll
    }

    var update: () -> AnyPublisher<Update, Never>

    var cache: () -> [Paste]

    var save: (Paste) -> Void
    var clean: () -> Void
}

extension HistoryManaging {

    static func inMemory() -> Self {

        var cache = Set<Paste>()
        let updateSubj = PassthroughSubject<Update, Never>()

        return HistoryManaging(
            update: {
                updateSubj.eraseToAnyPublisher()
            },
            cache: {
                cache.sorted()
            },
            save: {
                cache.insert($0)
                updateSubj.send(.insert($0))
            },
            clean: {
                cache.removeAll()
                updateSubj.send(.removeAll)
            }
        )
    }
}
