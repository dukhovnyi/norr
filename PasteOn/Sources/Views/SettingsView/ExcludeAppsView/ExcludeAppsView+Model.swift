//
//  ExcludeAppsView+Model.swift
//  Pasteon
//
//  Created by Yurii Dukhovnyi on 03.06.2023.
//

import AppKit
import Combine
import Foundation

extension ExcludeAppsView {

    final class Model: ObservableObject {

        @Published var apps: [ExcludeApps.App] = []
        @Published var recommended = [ExcludeApps.App]()

        init(excludeApps: ExcludeApps) {
            self.excludeApps = excludeApps

            let installedRecommendedApps = excludeApps.recommended()
                .compactMap { app in
                    let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app)
                    return url == nil ? nil : app
                }

            excludeApps.apps()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] apps in
                    self?.apps = apps
                    self?.recommended = installedRecommendedApps.filter { !apps.contains($0) }
                }
                .store(in: &cancellables)
        }

        func add(app: ExcludeApps.App) {
            excludeApps.add(app)
        }

        func remove(app: ExcludeApps.App) {
            excludeApps.remove(app)
        }

        // MARK: - Private

        private let excludeApps: ExcludeApps
        private var cancellables = Set<AnyCancellable>()
    }
}
