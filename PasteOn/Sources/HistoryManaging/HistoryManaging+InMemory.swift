//
//  HistoryManaging.InMemory.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 05.02.2023.
//

import Combine

extension HistoryManaging {

    static func inMemory(
        preferencesManaging: PreferencesManaging
    ) -> Self {

        var cache = Set<Paste>()
        let updateSubj = PassthroughSubject<Update, Never>()

        func alignCountWithCapacity() {
            var over = cache.count - preferencesManaging.current().storageCapacity
            guard over > 0 else { return }

            while over > 0 {
                if let min = cache.min(by: { $0.createdAt < $1.createdAt }) {
                    cache.remove(min)
                    updateSubj.send(.remove(min))
                }
                over -= 1
            }
        }

        return HistoryManaging(
            updates: {
                updateSubj.eraseToAnyPublisher()
            },
            cache: {
                cache.sorted { $0.createdAt > $1.createdAt }
            },
            save: {
                cache.insert($0)
                updateSubj.send(.append($0))
                alignCountWithCapacity()
            },
            remove: {
                cache.remove($0)
                updateSubj.send(.remove($0))
            },
            clean: {
                cache.removeAll()
                updateSubj.send(.removeAll)
            },
            pin: { paste in
                guard let idx = cache.firstIndex(where: { $0.id == paste.id }) else { return }
                var pinned = cache.remove(at: idx)
                pinned.isBolted = true
                cache.insert(pinned)
            },
            unpin: { paste in
                guard let idx = cache.firstIndex(where: { $0.id == paste.id }) else { return }
                var pinned = cache.remove(at: idx)
                pinned.isBolted = false
                cache.insert(pinned)
            }
        )
    }
}
