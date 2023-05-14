//
//  HistoryManaging.Mock.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 05.02.2023.
//

import Combine

extension HistoryManaging {

    static func mock(
        updateSubj: CurrentValueSubject<Update, Never> = .init(.removeAll),
        cache: @escaping () -> [Paste] = { [] },
        save: @escaping (Paste) -> Void = { _ in },
        remove: @escaping (Paste) -> Void = { _ in },
        clean: @escaping () -> Void = {},
        pin: @escaping (Paste) -> Void = { _ in },
        unpin: @escaping (Paste) -> Void = { _ in }
    ) -> Self {

        .init(
            updates: { updateSubj.eraseToAnyPublisher() },
            cache: cache,
            save: save,
            remove: remove,
            clean: clean,
            pin: pin,
            unpin: unpin
        )
    }
}
