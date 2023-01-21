//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import Carbon
import Combine
import Foundation

enum EventMonitor {
    typealias Interface = EventMonitorInterface

    struct Key: RawRepresentable, Equatable {
        var rawValue: UInt16

        static let enter: Self = .init(rawValue: CGKeyCode.kVK_Return)
        static let keypadEnter: Self = .init(rawValue: CGKeyCode.kVK_ANSI_KeypadEnter)
        static let delete: Self = .init(rawValue: CGKeyCode.kVK_Delete)
        static let forwardDelete: Self = .init(rawValue: CGKeyCode.kVK_ForwardDelete)
    }
}
