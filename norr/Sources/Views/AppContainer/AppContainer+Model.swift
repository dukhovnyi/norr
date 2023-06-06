//
//  AppContainer+Model.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 05.05.2023.
//

import AppKit
import Combine
import Foundation

extension AppContainer {

    final class Model: ObservableObject {

        let engine: Engine
        let appName: String
        let appVersion: String

        let hideUi: () -> Void
        
        init(
            engine: Engine,
            bundle: Bundle,
            hideUi: @escaping () -> Void
        ) {
            self.engine = engine
            self.appName = bundle.name
            self.appVersion = bundle.semver
            self.hideUi = hideUi

            handlePasteboardEvents()
        }

        func settingsClick() {
            if #available(macOS 13.0, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
        }

        // MARK: - Private

        private var pasteboardEventSubsciption: AnyCancellable?

        private func handlePasteboardEvents() {

            pasteboardEventSubsciption = engine.pasteboard.event
                .sink { [weak self] event in
                    switch event {
                    case .apply:
                        self?.hideUi()
                    default:
                        break
                    }
                }
        }
    }

}
