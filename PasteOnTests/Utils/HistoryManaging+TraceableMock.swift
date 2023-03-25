//
//  HistoryManaging+TraceableMock.swift
//  PasteOnTests
//
//  Created by Yurii Dukhovnyi on 25.03.2023.
//

import Foundation
@testable import PasteOn

extension HistoryManaging {

    enum Call: Equatable {
        case clean, cache, save(Paste)
    }

    static func traceableMock(call: @escaping (Call) -> Void) -> HistoryManaging {

        .mock(
            cache: {
                call(.cache)
                return []
            },
            save: { call(.save($0)) },
            clean: { call(.clean) }
        )
    }
}
