//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Foundation

enum AnalyticsController {

    typealias Interface = AnalyticsManagingInterface

    struct Event {
        let name: String
        let params: [String: Any]?
    }
}

protocol AnalyticsManagingInterface {

    func appDidFinishLaunching()

    func log(event: AnalyticsController.Event)
}

import FirebaseAnalytics
import FirebaseCore

extension AnalyticsController {

    final class Firebase: Interface {

        func appDidFinishLaunching() {
            Foundation.UserDefaults.standard.register(
              defaults: ["NSApplicationCrashOnExceptions" : true]
            )
            FirebaseApp.configure()
        }

        func log(event: AnalyticsController.Event) {
            Analytics.logEvent(
                event.name,
                parameters: event.params
            )
        }
    }
}

extension AnalyticsController {

    final class Previews: Interface {

        func appDidFinishLaunching() {}
        func log(event: AnalyticsController.Event) {}
    }
}
