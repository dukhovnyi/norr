//
//  AppDelegate.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    let worker = Worker()
    
    func applicationDidFinishLaunching(_ notification: Notification) {

        let statusBar = NSStatusBar.system

        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(
            systemSymbolName: "paperclip",
            accessibilityDescription: "Pasteboard"
        )

        let menu = NSMenu()
        menu.addItem(
            withTitle: "Open application",
            action: #selector(popup),
            keyEquivalent: ""
        )
        menu.addItem(
            withTitle: "Quit",
            action: #selector(quit),
            keyEquivalent: ""
        )

        statusBarItem?.menu = menu
        worker.start()
    }

    // MARK: - Private

    private var statusBarItem: NSStatusItem?

    @objc
    private func popup() {
        NSWorkspace.shared.open(URL(string: "pasteboard://")!)
    }

    @objc
    private func quit() {
        NSApplication.shared.terminate(self)
    }
}
