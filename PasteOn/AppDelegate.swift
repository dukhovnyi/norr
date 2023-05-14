//
//  AppDelegate.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import Combine
import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    let worker: Worker
    var cancellable: AnyCancellable?
    lazy var panel: FloatingPanel = {
        let onDidPaste: () -> Void = { [weak self] in
            self?.panel.orderOut(nil)
        }

        let dashbaord = Dashboard(
            viewModel: .init(
                worker: self.worker,
                onDidPaste: onDidPaste,
                analytics: self.analytics
            )
        )
        let contentView = dashbaord.edgesIgnoringSafeArea(.top)

        let _panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 700, height: 600), backing: .buffered, defer: false)
        _panel.title = "Floating Panel Title"
        _panel.contentView = NSHostingView(rootView: contentView)
        return _panel
    }()

    override init() {
        let preferencesManaging = PreferencesManaging.live()

        self.worker = .init(
            historyManaging: .coreData(managing: .live(name: "PasteboardHistory"), preferencesManaging: preferencesManaging),
            pasteboardManaging: .live(pasteboard: .general, interval: 1, now: { Date.now }),
            preferences: preferencesManaging
        )
        super.init()

        defer { worker.start() }

        KeyboardShortcuts.onKeyUp(for: .pasteboard) { [weak self] in
            self?.presentDashboard()
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {

#if DEBUG
#else
        analytics.appDidFinishLaunching(notification)
#endif
        let statusBar = NSStatusBar.system

        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(named: "statusbar-icon")

        let menu = NSMenu()

#if DEBUG
        let label = "Dev Edition"
#else
        let label = ""
#endif

        menu.addItem(
            .init(title: "\(Bundle.main.name): \(Bundle.main.semver) \(label)", action: nil, keyEquivalent: "")
        )

        staticMenuItems.forEach {
            menu.addItem($0)
        }

        statusBarItem?.menu = menu
    }

    // MARK: - Private

    private let analytics: AnalyticsManaging = .live()
    private var statusBarItem: NSStatusItem?

    @objc
    private func quit() {
        NSApplication.shared.terminate(self)
    }

    @objc
    private func cleanHistory() {

        worker.clear()
    }

    @objc
    private func openApp() {
        presentDashboard()
    }

    lazy var staticMenuItems: [NSMenuItem] = [
        NSMenuItem.separator(),
        NSMenuItem(title: "Open App", action: #selector(openApp), keyEquivalent: ""),
        NSMenuItem(title: "Clean history", action: #selector(cleanHistory), keyEquivalent: ""),
        NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q")
    ]

    private func presentDashboard() {
        // Center doesn't place it in the absolute center, see the documentation for more details
        panel.center()
        // Shows the panel and makes it active
        panel.orderFront(nil)
        panel.makeKey()
        panel.level = .floating
    }
}

extension CGRect {

    var center: CGPoint {
        .init(x: width / 2, y: height / 2)
    }
}
