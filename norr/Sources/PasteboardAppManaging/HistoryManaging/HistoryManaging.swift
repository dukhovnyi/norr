//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

enum HistoryManaging {

    typealias Interface = _HistoryManagingInterface

    enum Change { case append([Paste]), remove([Paste]) }
}

protocol _HistoryManagingInterface {

    /// Publiser that sends all changes happened in history.
    ///
    var change: AnyPublisher<HistoryManaging.Change, Never> { get }

    /// Stores pasteboard item and sends event to `change` publisher.
    ///
    func store(_ paste: Paste)

    /// Removes pasteboard item from storage and sends event to
    ///  `change` publisher.
    func remove(_ paste: Paste) -> AnyPublisher<Void, Error>

    /// Removes all pasteboard items from storage but favorites.
    ///
    func clean() -> AnyPublisher<Void, Error>

    /// Fetches requested amount of items after specific `createdAt`.
    /// If `createdAt` is missed, returns starting `now`.
    ///
    func fetch(_ fetchLimit: Int, after createdAt: Date?) -> AnyPublisher<[Paste], Error>

}

extension HistoryManaging {

    final class Previews: Interface {

        enum Call: Equatable {
            case store(Paste)
            case remove(Paste)
            case clean
            case fetch(Int, Date?)
        }
        var m_calls = [Call]()

        let change: AnyPublisher<HistoryManaging.Change, Never>

        init(
            change: PassthroughSubject<HistoryManaging.Change, Never> = .init(),
            fetch: Result<[Paste], Error> = .success([.mockPlainText(), .mockRtf(), .mockUrl(), .mockColor()])
        ) {
            self.change = change.eraseToAnyPublisher()
            self.fetchResult = fetch
        }

        func store(_ paste: Paste) {
            m_calls.append(.store(paste))
        }

        func remove(_ paste: Paste) -> AnyPublisher<Void, Error> {
            return Future {
                self.m_calls.append(.remove(paste))
                $0(.success(()))
            }
            .eraseToAnyPublisher()
        }

        func clean() -> AnyPublisher<Void, Error> {
            return Future {
                self.m_calls.append(.clean)
                $0(.success(()))
            }
            .eraseToAnyPublisher()
        }

        func fetch(
            _ fetchLimit: Int,
            after createdAt: Date?
        ) -> AnyPublisher<[Paste], Error> {
            Future {
                self.m_calls.append(.fetch(fetchLimit, createdAt))
                $0(self.fetchResult)
            }
            .eraseToAnyPublisher()
        }

        // MARK: - Private

        private let fetchResult: Result<[Paste], Error>
    }
}
