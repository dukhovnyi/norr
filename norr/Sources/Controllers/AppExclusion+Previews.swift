//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

extension AppExclusionController {

    final class Previews: Interface {

        var mock: [String] = []

        var apps: AnyPublisher<[String], Never>

        let recommendedForExclusion: [String] = [
            "com.apple.keychainaccess",
            "com.agilebits.onepassword7",
            "com.dashlane.dashlanephonefinal",
            "in.sinew.Enpass-Desktop",
            "com.mseven.msecuremac"
        ]

        init(apps: CurrentValueSubject<[String], Never> = .init([])) {
            self.apps = apps.eraseToAnyPublisher()
        }

        func exclude(bundleId: String) {
            mock.append(bundleId)
        }

        func removeExclusion(bundleId: String) {
            mock.removeAll(where: { $0 == bundleId })
        }
    }
}
