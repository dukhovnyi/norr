//
//  History+Preview.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import Combine
import Foundation

extension History {

    static func previews(
        updates: AnyPublisher<Update, Never> = PassthroughSubject().eraseToAnyPublisher(),
        fetchAll: @escaping () -> ([Paste]) = { [.mockPlainText(), .mockRtf(), .mockUrl(), .mockColor()] },
        append: @escaping (Paste) -> Void = { _ in },
        remove: @escaping (Paste) -> Void = { _ in },
        removeWithPredicate: @escaping (NSPredicate) -> Void = { _ in },
        update: @escaping (Paste) -> Void = { _ in },
        wipe: @escaping () -> Void = { }
    ) -> Self {

        return .init(
            updates: { updates },
            fetchAll: fetchAll,
            append: append,
            remove: remove,
            removeWithPredicate: removeWithPredicate,
            update: update,
            wipe: wipe
        )
    }
}