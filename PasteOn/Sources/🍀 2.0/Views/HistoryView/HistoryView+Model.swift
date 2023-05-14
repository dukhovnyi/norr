//
//  HistoryView+Model.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import Combine
import Foundation

extension HistoryView {

    final class Model: ObservableObject {

        @Published var items = [Paste]()
        @Published var selected: Paste?
        @Published var searchState = SearchState()
        @Published var search = ""
        @Published var caseSensitiveFilter = false

        init(engine: Engine) {
            self.history = engine.history

            items.append(contentsOf: self.history.fetchAll())
            
            self.subsciprtion = self.history.updates()
                .sink { [weak self] update in
                    switch update {
                    case .append(let newItems):
                        self?.items.insert(contentsOf: newItems, at: 0)
                    case .remove(let ids):
                        self?.items.removeAll(where: { ids.contains($0.id) })
                    case .update(let items):
                        items.forEach { item in
                            if let index = self?.items.firstIndex(where: { $0.id == item.id }) {
                                self?.items[index].isBolted = item.isBolted
                            }
                        }
                    }
                }

            searchSubsciprtion = $search.sink { [weak self] newSearch in
                self?.searchState.text = newSearch
            }
        }

        func remove(item: Paste) {
            history.remove(item)
        }

        func bolt(item: Paste) {
            var newItem = item
            newItem.isBolted.toggle()
            history.update(newItem)
        }

        // MARK: - Private

        private let history: History
        private var subsciprtion: AnyCancellable?
        private var searchSubsciprtion: AnyCancellable?
    }
}

extension HistoryView {

    struct AppGroup: Hashable {
        let bundle: URL
    }

}
