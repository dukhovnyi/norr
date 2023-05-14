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
        case append(Paste)
        case remove(Paste)
        case removeAll
        case update(Paste)
    }

    var updates: () -> AnyPublisher<Update, Never>

    var cache: () -> [Paste]

    var save: (Paste) -> Void
    var remove: (Paste) -> Void

    var clean: () -> Void

    var pin: (Paste) -> Void
    var unpin: (Paste) -> Void
}
