//
//  KeyboardShortcts+Name.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 27.02.2023.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {

    static let pasteboard = Self("display-panel", default: .init(.c, modifiers: [.command, .control]))
}
