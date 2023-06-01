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

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    let engine = Engine(
        history: .live(persistentContainerName: "PasteboardHistory"),
        pasteboard: .live(pasteboard: .general, interval: 0.7, now: { .now })
    )
    let bundle = Bundle.main

    var cancellable: AnyCancellable?
    lazy var panel: FloatingPanel = {
        let hideUi: () -> Void = { [weak self] in
            self?.panel.orderOut(nil)
        }

        let app = AppContainer(
            model: .init(engine: self.engine, bundle: self.bundle, hideUi: hideUi)
        )

        let _panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 700, height: 600), backing: .buffered, defer: false)
        _panel.title = ""
        _panel.contentView = NSHostingView(rootView: app)
        return _panel
    }()

    override init() {

        super.init()

        engine.start()

        KeyboardShortcuts.onKeyUp(for: .pasteboard) { [weak self] in
            self?.showPanel()
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
        engine.history.wipe()
    }

    @objc
    private func openApp() {
        showPanel()
    }

    lazy var staticMenuItems: [NSMenuItem] = [
        NSMenuItem.separator(),
        NSMenuItem(title: "Open App", action: #selector(openApp), keyEquivalent: ""),
        NSMenuItem(title: "Clean history", action: #selector(cleanHistory), keyEquivalent: ""),
        NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q")
    ]

    private func showPanel() {

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
