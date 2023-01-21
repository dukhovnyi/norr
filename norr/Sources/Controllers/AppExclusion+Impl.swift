//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

extension AppExclusionController {

    final class Impl: Interface {

        var apps: AnyPublisher<[String], Never> {
            appsSubj.eraseToAnyPublisher()
        }

        let recommendedForExclusion: [String] = [
            "com.apple.keychainaccess",
            "com.agilebits.onepassword7",
            "com.dashlane.dashlanephonefinal",
            "in.sinew.Enpass-Desktop",
            "com.mseven.msecuremac"
        ]

        init(quickStorage: QuickStorage.Interface) {

            self.quickStorage = quickStorage

            setup()
        }

        func exclude(bundleId: String) {

            guard !excludedApps.contains(bundleId) else { return }
            excludedApps.append(bundleId)
        }

        func removeExclusion(bundleId: String) {
            guard excludedApps.contains(bundleId) else { return }
            excludedApps.removeAll(where: { $0 == bundleId})
        }

        // MARK: - Private

        private let quickStorage: QuickStorage.Interface

        private let appsSubj = CurrentValueSubject<[String], Never>([])

        private var excludedApps = [String]() {
            didSet {
                quickStorage.write(value: excludedApps, forKey: "excluded-apps")
                appsSubj.send(excludedApps)
            }
        }

        private func setup() {

            excludedApps = quickStorage.read(forKey: "excluded-apps") ?? []
        }
    }

}
