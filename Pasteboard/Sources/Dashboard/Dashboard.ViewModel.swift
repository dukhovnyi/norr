//
//  Dashboard.ViewModel.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 05.02.2023.
//

import Combine
import Foundation

extension Dashboard {

    final class ViewModel: ObservableObject {

        @Published var items = [Paste]()

        init(
            keeper: Keeper
        ) {
            self.keeper = keeper

            items = keeper.history.cache()
            updateSubscription = keeper.history.update()
                .receive(on: RunLoop.main)
                .sink { [weak self] update in

                    switch update {

                    case .removeAll:
                        self?.items.removeAll()

                    case .remove(let item):
                        self?.items.removeAll(where: { $0 == item })

                    case .insert(let item):
                        self?.items.insert(item, at: 0)
                    }

                }
        }

        func cleanHistory() {
            keeper.history.clean()
        }

        func use(paste: Paste) {
            keeper.use(paste: paste)
        }

        // MARK: - Private

        private let keeper: Keeper
        private var updateSubscription: AnyCancellable?
    }
}
