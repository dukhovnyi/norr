//
//  Paste+Content.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 19.02.2023.
//

import AppKit

extension Paste {

    struct Content: Hashable {
        let type: NSPasteboard.PasteboardType
        let value: Data?
    }
}
