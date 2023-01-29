//
//  AppDelegate.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {

    let keeper: Keeper
    var cancellable: AnyCancellable?

    override init() {
        self.keeper = .init(
            pasteboard: .general,
            preferences: .live(),
            storage: .inMemory()
        )
        super.init()

        defer { keeper.start() }

        cancellable = keeper.history.update()
            .sink { [weak self] update in

                guard let self else { return }

                switch update {
                case .insert(let newPaste):
                    self.statusBarItem?.menu?.items.first(where: { $0.keyEquivalent == "3" })?.keyEquivalent = ""
                    self.statusBarItem?.menu?.items.first(where: { $0.keyEquivalent == "2" })?.keyEquivalent = "3"
                    self.statusBarItem?.menu?.items.first(where: { $0.keyEquivalent == "1" })?.keyEquivalent = "2"

                    let menuItem = self.statusBarItem?.menu?.insertItem(
                        withTitle: newPaste.stringRepresentation,
                        action: #selector(self.moveToPasteboard),
                        keyEquivalent: "1",
                        at: 0
                    )
                    menuItem?.tag = newPaste.id
                case .removeAll:
                    self.statusBarItem?.menu?.items.removeAll { !self.staticMenuItems.contains($0) }
                }
            }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {

        let statusBar = NSStatusBar.system

        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(
            systemSymbolName: "paperclip",
            accessibilityDescription: "Pasteboard"
        )

        let menu = NSMenu()

        staticMenuItems.forEach {
            menu.addItem($0)
        }

        statusBarItem?.menu = menu
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

    @objc
    private func moveToPasteboard(sender: NSMenuItem) {

        keeper.paste(sender.tag)
    }

    @objc
    private func cleanHistory() {

        keeper.history.clean()
    }

    lazy var staticMenuItems: [NSMenuItem] = [
        NSMenuItem.separator(),
        NSMenuItem(title: "Clean history", action: #selector(cleanHistory), keyEquivalent: ""),
        NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q")
    ]
}
