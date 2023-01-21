//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import Combine
import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    let app: PasteboardAppManaging.Interface

    override init() {
        
        CoreDataManager.cleanUp()
        
        let quickStorage = QuickStorage.UserDefaultsImpl(userDefaults: .standard)

        self.app = PasteboardAppManaging.Impl(
            analyticsController: AnalyticsController.Firebase(),
            appExclusionController: AppExclusionController.Impl(quickStorage: quickStorage),
            historyController: HistoryManaging.InMemory(),
            pasteboard: PasteboardManaging.Impl(
                pasteboard: PasteboardInstance.Impl(pasteboard: .general),
                dependency: PasteboardManaging.DependencyImpl(),
                timer: TimerManaging.Impl(),
                updateInterval: 0.7
            )
        )
        super.init()

        guard NSClassFromString("XCTestCase") == nil else {
            return
        }
        
        KeyboardShortcuts.reset(.norr)
        KeyboardShortcuts.onKeyUp(for: .norr) { [weak self] in
            self?.presentAppPanel()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {

#if DEBUG
#else
        app.analyticsController.appDidFinishLaunching()
#endif
        popup.orderFront()
    }

    func presentAppPanel() {

        popup.orderFront()
    }

    // MARK: - Private

    private lazy var popup: PopupPanel = {

        return PopupPanel { [unowned self] in
            PopupContainerView(
                app: self.app,
                eventMonitor: EventMonitor.Impl()
            )
                .ignoresSafeArea()
                .padding(.top, -54)
                .frame(width: 700, height: 580)
                .background(VisualEffect())
                .environment(\.floatingPanel, popup.panel)
        }
    }()
}
