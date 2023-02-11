//
//  Dashboard.ViewModel.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 05.02.2023.
//

import AppKit
import Combine
import Foundation
import SwiftUI

extension Dashboard {

    final class ViewModel: ObservableObject {

        @Published var selected: Set<Paste> = []
        @Published var items = [Paste]()
        @Published var content: Content
        @Published var state: Keeper.State

        @Published var stateButtonTitle = String()
        @Published var stateButtoneImageName = String()

        var onDidPaste: () -> Void

        init(
            keeper: Keeper,
            onDidPaste: @escaping () -> Void,
            content: Content = .pasteboardList,
            state: Keeper.State = .inactive
        ) {
            self.keeper = keeper
            self.onDidPaste = onDidPaste
            self.content = content
            self.state = state

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

            self.stateSubscriptions = keeper.state
                .throttle(for: .seconds(3), scheduler: DispatchQueue.main, latest: true)
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] newState in
                    self?.state = newState

                    switch newState {
                    case .active:
                        self?.stateButtonTitle = "Suspend"
                        self?.stateButtoneImageName = "pause"
                    case .inactive:
                        self?.stateButtonTitle = "Resume"
                        self?.stateButtoneImageName = "play"
                    }
                })
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

        func preferencesClick() {
            withAnimation {
                content = content == .pasteboardList ? .preferences : .pasteboardList
            }
        }

        @ViewBuilder var preferencesButtonImage: some View {

            switch content {
            case .pasteboardList:
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 24, height: 24)
            case .preferences:
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: 12, height: 24)
            }
        }

        // MARK: - Private

        private let keeper: Keeper
        private var stateSubscriptions: AnyCancellable?
        private var updateSubscription: AnyCancellable?
        private var cancellables = Set<AnyCancellable>()
        private var eventMonitor: Any?
    }
}

extension Dashboard.ViewModel {

    enum Content {
        case pasteboardList, preferences
    }
}

extension Dashboard.ViewModel {

    func start() {
        keeper.start()
    }

    func stateToggle() {

        keeper.state
            .prefix(1)
            .sink { [weak self] currentState in
                switch currentState {
                case .inactive:
                    self?.keeper.start()
                case .active:
                    self?.keeper.stop()
                }
            }
            .store(in: &cancellables)
    }
}
