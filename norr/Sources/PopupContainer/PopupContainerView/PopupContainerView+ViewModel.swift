//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

extension PopupContainerView {

    final class ViewModel: ObservableObject {

        enum Row: Equatable, Identifiable, Hashable {
            case paste(Paste), loadMore

            var id: String {
                pasteItem?.id ?? "load-more"
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }

            var pasteItem: Paste? {
                switch self {
                case .loadMore:
                    return nil
                case .paste(let item):
                    return item
                }
            }
        }

        @Published var rows: [Row] = [.loadMore]
        @Published var selection: Row?


        let app: PasteboardAppManaging.Interface
        var hideFloatingPanelPublisher: AnyPublisher<Void, Never> {
            hideFloatingPanelSubject.eraseToAnyPublisher()
        }

        init(
            app: PasteboardAppManaging.Interface,
            eventMonitor: EventMonitor.Interface
        ) {
            self.app = app
            self.eventMonitor = eventMonitor

            setup()
            debugPrint("PopupContainerView.ViewModel has initialized.")
        }

        deinit {
            debugPrint("~PopupContainerView.ViewModel has deinitialized.")
        }

        func loadMore() {

            switch rows.last {
            case .loadMore:
                let createdAt = rows.last(where: { $0.pasteItem != nil }).map(\.pasteItem)??.createdAt
                app.historyController
                    .fetch(Self.paginationStep, after: createdAt)
                    .subscribe(on: DispatchQueue.global(qos: .background))
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        guard case .failure(let error) = completion else { return }
                        debugPrint("💥 Load more items, strating from '\(createdAt?.description ?? "")' failed. Error='\(error)'.")
                    } receiveValue: { [weak self] items in
                        self?.rows.removeAll(where: { $0 == .loadMore })
                        self?.rows.append(contentsOf: items.map { .paste($0) })
                        if items.count == Self.paginationStep {
                            self?.rows.append(.loadMore)
                        }
                    }
                    .store(in: &cancellables)
            default:
                break
            }
        }

        func setPastboardItem(_ paste: Paste) {

            app.pasteboard.setPasteboardItem(to: paste)
        }

        func deletePasteItem(_ paste: Paste) {

            app.historyController.remove(paste)
                .sink { opCompletion in
                    guard case .failure(let error) = opCompletion else { return }
                    debugPrint("💥 Pasteboard item has not been deleted from history. Error='\(error)'.")
                } receiveValue: {}
                .store(in: &cancellables)

        }

        // MARK: - Private

        private static let paginationStep = 50
        private let eventMonitor: EventMonitor.Interface
        private let hideFloatingPanelSubject = PassthroughSubject<Void, Never>()
        private var cancellables = Set<AnyCancellable>()

        private func setup() {

            app.historyController
                .change
                .sink { [weak self] change in

                    switch change {

                    case .append(let newItems):
                        self?.rows.insert(contentsOf: newItems.map { .paste($0) }, at: 0)

                    case .remove(let removedItems):
                        self?.rows.removeAll(where: { row in
                            removedItems.contains(where: { row.pasteItem?.id == $0.id })
                        })
                    }
                }
                .store(in: &cancellables)

            eventMonitor.publisher
                .sink { [weak self] key in
                    guard
                        let self,
                            let selection = self.selection?.pasteItem
                    else { return }

                    switch key {
                    case .delete, .forwardDelete:
                        self.deletePasteItem(selection)
                    case .enter, .keypadEnter:
                        self.setPastboardItem(selection)
                        self.hideFloatingPanelSubject.send(())
                    default:
                        break
                    }
                }
                .store(in: &cancellables)
        }
    }
}
