//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import Combine
import SwiftUI

/// An NSPanel subclass that implements floating panel traits.
///
final class FloatingPanel: NSPanel {

    var orderedOut: AnyPublisher<Void, Never> { 
        orderedOutSubj.eraseToAnyPublisher()
    }

    init(
        contentRect: NSRect,
        backing: NSWindow.BackingStoreType = .buffered,
        defer flag: Bool = false
    ) {

        /// Init the window as usual
        super.init(
            contentRect: contentRect,
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .resizable,
                .closable,
                .fullSizeContentView
            ],
            backing: backing,
            defer: flag
        )

        /// Allow the panel to be on top of other windows
        isFloatingPanel = true
        level = .floating

        /// Allow the pannel to be overlaid in a fullscreen space
        collectionBehavior.insert(
            .fullScreenAuxiliary
        )

        /// Don't show a window title, even if it's set
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        /// Since there is no title bar make the window moveable by dragging on the background
        isMovableByWindowBackground = true

        /// Hide all traffic light buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        /// Sets animations accordingly
        animationBehavior = .utilityWindow

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

    @objc func didResignKeyNotification() {
        orderedOutSubj.send(())
        orderOut(nil)
    }

    // MARK: - Private

    private let orderedOutSubj = PassthroughSubject<Void, Never>()
}

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: FloatingPanel? = nil
}

extension EnvironmentValues {
    var floatingPanel: FloatingPanel? {
        get {
            self[FloatingPanelKey.self]
        }
        set {
            self[FloatingPanelKey.self] = newValue
        }
    }
}
