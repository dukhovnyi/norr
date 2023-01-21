//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import Combine
import Foundation

extension AppExclusionsSettingView {

    final class ViewModel: ObservableObject {

        @Published var apps: [String] = []
        @Published var recommended = [String]()

        init(appExclusionController: AppExclusionController.Interface) {
            self.appExclusionController = appExclusionController

            setup()
        }

        func add(bundleId: String) {
            appExclusionController.exclude(bundleId: bundleId)
        }

        func remove(bundleId: String) {
            appExclusionController.removeExclusion(bundleId: bundleId)
        }

        func openPanel() {

            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.title = "Please choose application you would like to add to exclusion"

            if panel.runModal() == .OK,
                let url = panel.url,
                let bundleIdentifier = Bundle(url: url)?.bundleIdentifier {

                appExclusionController.exclude(bundleId: bundleIdentifier)
            }
        }

        // MARK: - Private

        private let appExclusionController: AppExclusionController.Interface
        private var cancellables = Set<AnyCancellable>()

        private func setup() {

            let installedRecommendedApps = appExclusionController.recommendedForExclusion
                .compactMap { app in
                    let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app)
                    return url == nil ? nil : app
                }

            appExclusionController.apps
                .receive(on: DispatchQueue.main)
                .sink { [weak self] apps in
                    self?.apps = apps
                    self?.recommended = installedRecommendedApps.filter { !apps.contains($0) }
                }
                .store(in: &cancellables)
        }
    }
}
