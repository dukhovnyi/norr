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
        case remove(Paste)
        case removeAll
    }

    var updates: () -> AnyPublisher<Update, Never>

    var cache: () -> [Paste]

    var save: (Paste) -> Void

    var clean: () -> Void
}
