//
//  PasteboardManaging+TraceableMock.swift
//  noorTests
//
//  Created by Yurii Dukhovnyi on 25.03.2023.
//

import Foundation
@testable import noor

extension PasteboardManaging {

    enum Call {
        case start, stop, apply
    }

    static func traceableMock(call: @escaping (Call) -> Void) -> PasteboardManaging {

        PasteboardManaging.mock(
            onStart: { call(.start) },
            onStop: { call(.stop) },
            onApply: { call(.apply) }
        )
    }
}
