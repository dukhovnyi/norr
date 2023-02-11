//
//  FloatingPanel.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 11.02.2023.
//

import AppKit

class FloatingPanel: NSPanel {
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {

        // Not sure if .titled does affect anything here. Kept it because I think it might help with accessibility but I did not test that.
        super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel, .titled, .closable, .fullSizeContentView], backing: backing, defer: flag)

        // Set this if you want the panel to remember its size/position
        //        self.setFrameAutosaveName("a unique name")

        // Allow the pannel to be on top of almost all other windows
        self.isFloatingPanel = true
        self.level = .floating

        // Allow the pannel to appear in a fullscreen space
        self.collectionBehavior.insert(.fullScreenAuxiliary)

        // While we may set a title for the window, don't show it
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true

        // Since there is no titlebar make the window moveable by click-dragging on the background
        self.isMovableByWindowBackground = true

        // Keep the panel around after closing since I expect the user to open/close it often
        self.isReleasedWhenClosed = false

        // Activate this if you want the window to hide once it is no longer focused
        //        self.hidesOnDeactivate = true

        // Hide the traffic icons (standard close, minimize, maximize buttons)
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeKeyNotification),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didResignKeyNotification),
            name: NSWindow.didResignKeyNotification,
            object: nil
        )
    }

    // `canBecomeKey` and `canBecomeMain` are required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    @objc func didBecomeKeyNotification() {}
    @objc func didResignKeyNotification() { orderOut(nil) }
}
