//
// Copyright © 2024 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

extension HistoryManaging {

    final class InMemory: Interface {

        var change: AnyPublisher<HistoryManaging.Change, Never> {
            changeSubj.eraseToAnyPublisher()
        }

        func store(_ paste: Paste) {
            cache.insert(paste, at: 0)
            self.changeSubj.send(.append([paste]))
        }
        
        func remove(_ paste: Paste) -> AnyPublisher<Void, Error> {
            Future { [weak self] completion in
                self?.cache.removeAll(where: { $0.id == paste.id })
                self?.changeSubj.send(.remove([paste]))
                completion(.success(()))
            }.eraseToAnyPublisher()
        }
        
        func clean() -> AnyPublisher<Void, Error> {
            Future { [weak self] completion in
                guard let self else { return }
                self.cache.removeAll()
                self.changeSubj.send(.remove(self.cache))
                completion(.success(()))
            }.eraseToAnyPublisher()
        }
        
        func fetch(_ fetchLimit: Int, after createdAt: Date?) -> AnyPublisher<[Paste], Error> {
            Future { [weak self] completion in
                guard let self else { return }
                let result = Array(
                    cache.filter { $0.createdAt < createdAt ?? .init() }
                        .prefix(fetchLimit)
                )
                completion(
                    .success(result)
                )
            }.eraseToAnyPublisher()
        }

        // MARK: - Private

        private let changeSubj = PassthroughSubject<HistoryManaging.Change, Never>()

        private var cache = [Paste]()
    }

}
