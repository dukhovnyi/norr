//
//  Dashboard.ViewModel.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 05.02.2023.
//

import AppKit
import Combine
import Foundation

extension Dashboard {

    final class ViewModel: ObservableObject {

        @Published var selected: Set<Paste> = []
        @Published var items = [Paste]()

        var onDidPaste: () -> Void

        init(
            keeper: Keeper,
            onDidPaste: @escaping () -> Void
        ) {
            self.keeper = keeper
            self.onDidPaste = onDidPaste

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
            onDidPaste()
        }

        func onAppear() {

            self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in

                guard let self = self, let paste = self.selected.first else { return event }

                if event.keyCode == 36 {
                    self.use(paste: paste)
                }
                return event
            }
        }

        func onDisappear() {

            if let eventMonitor {
                NSEvent.removeMonitor(eventMonitor)
            }
        }

        // MARK: - Private

        private let keeper: Keeper
        private var updateSubscription: AnyCancellable?

        private var eventMonitor: Any?
    }
}
