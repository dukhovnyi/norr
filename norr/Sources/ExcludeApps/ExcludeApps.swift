//
//  ExcludeApps.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 03.06.2023.
//

import Combine
import Foundation

struct ExcludeApps {

    typealias App = String

    var apps: () -> AnyPublisher<[App], Never>
    var add: (App) -> Void
    var remove: (App) -> Void

    var isExcluded: (App) -> Bool

    var recommended: () -> [App]
}

extension ExcludeApps {

    static func live(analytics: AnalyticsManaging) -> Self {

        @UserDefaults(key: "excluded-apps", defaultValue: Set<App>())
        var _apps: Set<App>
        let apps = CurrentValueSubject<[App], Never>(_apps.sorted())
        let valueDidChange = { apps.send(_apps.sorted()) }

        return .init(
            apps: {
                apps.eraseToAnyPublisher()
            },
            add: {
                _apps.insert($0)
                valueDidChange()
                analytics.logEvent(.addExcludedApp(bundleId: $0))
            },
            remove: {
                _apps.remove($0);
                valueDidChange()
                analytics.logEvent(.removeExcludedApp(bundleId: $0))
            },
            isExcluded: {
                _apps.contains($0)
            },
            recommended: {
                recommendedBundleIds
            }
        )
    }
}

extension ExcludeApps {

    static func previews(_ previewsApps: [App] = []) -> Self {
        var _apps = previewsApps
        let apps = CurrentValueSubject<[App], Never>(_apps)
        return .init(
            apps: { apps.eraseToAnyPublisher() },
            add: { _apps.append($0) },
            remove: { app in _apps.removeAll(where: { $0 == app }) },
            isExcluded: { _apps.contains($0) },
            recommended: { recommendedBundleIds }
        )
    }
}

private let recommendedBundleIds = [
    "com.apple.keychainaccess",
    "com.agilebits.onepassword7",
    "com.dashlane.dashlanephonefinal",
    "in.sinew.Enpass-Desktop",
    "com.mseven.msecuremac"
]
