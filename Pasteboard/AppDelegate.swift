//
//  AppDelegate.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit
import Combine
import HotKey
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    let keeper: Keeper
    var cancellable: AnyCancellable?

    let hotKey = HotKey(key: .c, modifiers: [.command, .control])

    var panel: FloatingPanel?

    override init() {

        let preferencesManaging: PreferencesManaging = .live()

        self.keeper = .init(
            pasteboard: .general,
            preferencesManaging: preferencesManaging,
            storage: .inMemory(preferencesManaging: preferencesManaging)
        )
        super.init()

        defer { keeper.start() }

        hotKey.keyDownHandler = { [weak self] in
//            self?.statusBarItem?.menu?.popUp(positioning: nil, at: NSScreen.main?.visibleFrame.center ?? .zero, in: nil)
//            self?.windowController = .init(window: .init(contentViewController: NSHostingController(rootView: ContentView(viewModel: .init()))))
            self?.createFloatingPanel()

            // Center doesn't place it in the absolute center, see the documentation for more details
            self?.panel?.center()

            // Shows the panel and makes it active
            self?.panel?.orderFront(nil)
            self?.panel?.makeKey()
//            self?.panel?.level = .floating
        }

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

                case .remove(let item):
                    self.statusBarItem?.menu?.items.removeAll(where: { $0.tag == item.id })
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
            viewModel: .init(keeper: self.keeper, onDidPaste: onDidPaste)
        )
        let contentView = dashbaord
            .edgesIgnoringSafeArea(.top)
        // Create the window and set the content view.
        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 700, height: 333), backing: .buffered, defer: false)
        panel?.title = "Floating Panel Title"
        panel?.contentView = NSHostingView(rootView: contentView)
    }
}

extension CGRect {

    var center: CGPoint {
        .init(x: width / 2, y: height / 2)
    }
}
