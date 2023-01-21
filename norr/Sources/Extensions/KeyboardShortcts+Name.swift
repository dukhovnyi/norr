//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {

    static let norr = Self("display-panel", default: .init(.c, modifiers: [.command, .control]))
}

enum Shortcut {

    static var stringRepresentation: String {
        
        guard let shortcut = KeyboardShortcuts.getShortcut(for: .norr) else {
            return "Cmd+Ctrl+C"
        }
        
        return "\(shortcut)"
    }
}
