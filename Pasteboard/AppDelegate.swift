//
//  AppDelegate.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import Combine
import KeyboardShortcuts
import Sentry
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    let worker: Worker
    var cancellable: AnyCancellable?
    var panel: FloatingPanel?

    override init() {
        let preferencesManaging = PreferencesManaging.live()

        self.worker = .init(
            historyManaging: .coreData(coreDataManaging: .live(name: "PasteboardHistory"), preferencesManaging: preferencesManaging),
            pasteboardManaging: .live(pasteboard: .general, interval: 1, now: { Date.now }),
            preferences: preferencesManaging
        )
        super.init()

        defer { worker.start() }

        KeyboardShortcuts.onKeyUp(for: .pasteboard) { [weak self] in
            self?.createFloatingPanel()

            // Center doesn't place it in the absolute center, see the documentation for more details
            self?.panel?.center()

            // Shows the panel and makes it active
            self?.panel?.orderFront(nil)
            self?.panel?.makeKey()
            self?.panel?.level = .floating
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {

        SentrySDK.start { opts in
            opts.dsn = "https://d06222e078c742e99a8720270e39b112@o4504754069766144.ingest.sentry.io/4504754071404544"
            opts.debug = true // Enabled debug when first installing is always helpful

            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            opts.tracesSampleRate = 1.0
        }

        let statusBar = NSStatusBar.system

        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(named: "statusbar-icon")

        let menu = NSMenu()

        staticMenuItems.forEach {
            menu.addItem($0)
        }

        statusBarItem?.menu = menu
    }

    // MARK: - Private

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
        // Center doesn't place it in the absolute center, see the documentation for more details
        panel?.center()

        // Shows the panel and makes it active
        panel?.orderFront(nil)
        panel?.makeKey()
    }

    lazy var staticMenuItems: [NSMenuItem] = [
        NSMenuItem.separator(),
        NSMenuItem(title: "Open App", action: #selector(openApp), keyEquivalent: ""),
        NSMenuItem(title: "Clean history", action: #selector(cleanHistory), keyEquivalent: ""),
        NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q")
    ]



    private func createFloatingPanel() {
        let onDidPaste: () -> Void = { [weak self] in
            self?.panel?.orderOut(nil)
        }
        // Create the SwiftUI view that provides the window contents.
        // I've opted to ignore top safe area as well, since we're hiding the traffic icons
        let dashbaord = Dashboard(
            viewModel: .init(worker: self.worker, onDidPaste: onDidPaste)
        )
        let contentView = dashbaord
            .edgesIgnoringSafeArea(.top)
        // Create the window and set the content view.
        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 700, height: 600), backing: .buffered, defer: false)
        panel?.title = "Floating Panel Title"
        panel?.contentView = NSHostingView(rootView: contentView)
    }
}

extension CGRect {

    var center: CGPoint {
        .init(x: width / 2, y: height / 2)
    }
}
