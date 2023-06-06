//
//  History.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 30.04.2023.
//

import Combine
import Foundation

struct History {

    var updates: () -> AnyPublisher<Update, Never>

    var fetchAll: () -> ([Paste])

    var append: (Paste) -> Void
    var remove: (Paste) -> Void
    var removeWithPredicate: (NSPredicate) -> Void
    
    var update: (Paste) -> Void

    var wipe: () -> Void
}

extension History {
    enum Update {
        case append([Paste])
        case remove([Paste.ID])
        case removeAll
        case update([Paste])
    }
}