//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import Foundation

/// This namespace contains wrapper for `NSPasteboard` for injection purposes.
enum PasteboardInstance {

    typealias Interface = _PasteboardInstanceInterface
}

protocol _PasteboardInstanceInterface {

    /// The change count starts at zero when a client creates the receiver
    /// and becomes the first owner. The change count subsequently increments
    /// each time the pasteboard ownership changes.
    var changeCount: Int { get }

    /// An array that contains all the items held by the pasteboard.
    var pasteboardItems: [NSPasteboardItem]? { get }

    /// Applies pasteboard items to current pasteboard.
    func apply(paste: Paste)
}

extension PasteboardInstance {

    final class Impl: Interface {

        var changeCount: Int {
            pasteboard.changeCount
        }

        var pasteboardItems: [NSPasteboardItem]? {
            pasteboard.pasteboardItems
        }

        init(pasteboard: NSPasteboard) {
            self.pasteboard = pasteboard
        }

        func apply(paste: Paste) {

            pasteboard.clearContents()

            paste.representations.forEach {
                pasteboard.setData(
                    $0.data,
                    forType: $0.type
                )
            }
        }

        // MARK: - Private

        private let pasteboard: NSPasteboard
    }

}

extension PasteboardInstance {

    final class Mock: Interface {
        
        enum Call: Equatable {
            case apply(Paste)
        }

        var m_calls = [Call]()
        var m_pasteboard = NSPasteboard(name: .init(rawValue: "Mocked Pacteboard"))

        var changeCount: Int = 0
        var pasteboardItems: [NSPasteboardItem]? {
            m_pasteboard.pasteboardItems
        }

        func apply(paste: Paste) {
            m_pasteboard.clearContents()
            paste.representations.forEach {
                m_pasteboard.setData(
                    $0.data,
                    forType: $0.type
                )
            }
            m_calls.append(.apply(paste))
        }
    }
}
