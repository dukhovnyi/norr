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
        clean: @escaping () -> Void = {}
    ) -> Self {

        .init(
            update: { updateSubj.eraseToAnyPublisher() },
            cache: cache,
            save: save,
            clean: clean
        )
    }
}
