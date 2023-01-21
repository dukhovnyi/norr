//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import KeyboardShortcuts
import SwiftUI

struct NorrApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {

        MenuBarExtra {
            AppMenu(
                viewModel: .init(
                    openApp: { delegate.presentAppPanel() },
                    quitApp: { NSApplication.shared.terminate(self) }
                )
            )

        } label: {
            Image("icon")
        }

        Settings {
            SettingsView(
                appExclusionController: delegate.app.appExclusionController,
                historyController: delegate.app.historyController
            )
        }
    }
}


@main
struct MainEntryPoint {
    static func main() {
        if isTestCase() {
            TestCaseApp.main()
        } else {
            NorrApp.main()
        }
    }

    private static func isTestCase() -> Bool {
        NSClassFromString("XCTestCase") != nil
    }
}

struct TestCaseApp: App {
    var body: some Scene {
        WindowGroup {
        }
    }
}
