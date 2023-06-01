//
//  PasteboardManaging+Mock.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 26.02.2023.
//

import Combine
import Foundation

extension PasteboardManaging {

    static func mock(
        now: @escaping () -> Date = { Date.now },
        onStart: @escaping () -> Void = {},
        onStop: @escaping () -> Void = {},
        onApply: @escaping () -> Void = {},
        event: PassthroughSubject<Event, Never> = .init(),
        value: PassthroughSubject<Paste, Never> = .init()
    ) -> Self {

        return .init(
            event: event.eraseToAnyPublisher(),
            value: value.eraseToAnyPublisher(),
            start: onStart,
            stop: onStop,
            apply: { _ in
                onApply()
            }
        )

    }

}
