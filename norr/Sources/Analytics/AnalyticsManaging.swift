//
//  AnalyticsManaging.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 03.03.2023.
//

import Foundation

struct AnalyticsManaging {

    let appDidFinishLaunching: (_ notification: Notification) -> Void
    let logEvent: (Event) -> Void

}

extension AnalyticsManaging {

    struct Event {
        let name: String
        let params: [String: Any]?

        static let openPreferencesFromDashboard = Event(name: "open_preferences__from_dashboard", params: nil)

        // Exclude app
        static func addExcludedApp(bundleId: String) -> Event {
            Event(name: "add_app_exclusion", params: ["bundleId": bundleId])
        }
        static func removeExcludedApp(bundleId: String) -> Event {
            Event(name: "remove_app_exclusion", params: ["bundleId": bundleId])
        }
        static let maxRetainPeriodAchieved = Event(name: "max_retain_period_achieved", params: nil)
    }
    
}


import FirebaseAnalytics
import FirebaseCore

extension AnalyticsManaging {

    static func live() -> Self {

        AnalyticsManaging(
            appDidFinishLaunching: { _ in

                Foundation.UserDefaults.standard.register(
                  defaults: ["NSApplicationCrashOnExceptions" : true]
                )
                FirebaseApp.configure()
                
            },
            logEvent: {
                Analytics.logEvent($0.name, parameters: $0.params)
            }
        )
    }

    static func previews() -> Self {
        AnalyticsManaging(
            appDidFinishLaunching: { _ in },
            logEvent: { _ in }
        )
    }
}
