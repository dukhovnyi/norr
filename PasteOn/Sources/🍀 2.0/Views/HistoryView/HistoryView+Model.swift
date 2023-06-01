//
//  HistoryView+Model.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import AppKit
import AVFoundation
import Carbon.HIToolbox
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
            self.engine = engine

            items.append(contentsOf: self.engine.history.fetchAll())
            
            self.subsciprtion = self.engine.history.updates()
                .sink { [weak self] update in
                    switch update {
                    case .append(let newItems):
                        self?.items.insert(contentsOf: newItems, at: 0)
                    case .remove(let ids):
                        self?.items.removeAll(where: { ids.contains($0.id) })
                    case .removeAll:
                        self?.items.removeAll()
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

            startEventMonitor()
        }

        deinit {
            if let eventMonitorRef {
                NSEvent.removeMonitor(eventMonitorRef)
            }
        }

        func remove(item: Paste) {
            engine.history.remove(item)
        }

        func bolt(item: Paste) {
            var newItem = item
            newItem.isBolted.toggle()
            engine.history.update(newItem)
        }

        func apply(item: Paste) {
            engine.pasteboard.apply(item)
            AudioServicesPlaySystemSound(kUserPreferredAlert)
        }

        // MARK: - Private

        private var eventMonitorRef: Any?
        private let engine: Engine

        private var subsciprtion: AnyCancellable?
        private var searchSubsciprtion: AnyCancellable?

        private func startEventMonitor() {

            eventMonitorRef = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
                guard let self, let selected = self.selected, event.keyCode == kVK_Return else { return event }
                self.apply(item: selected)
                return event
            }
        }
    }
}

extension HistoryView {

    struct AppGroup: Hashable {
        let bundle: URL
    }

}
