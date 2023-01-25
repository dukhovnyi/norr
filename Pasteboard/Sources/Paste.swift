//
//  Paste.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit

struct Paste: Identifiable, CustomStringConvertible {

    let id: Int
    let contents: [Content]

    init(
        pasteboard: NSPasteboard
    ) {
        self.id = pasteboard.changeCount
        self.contents = pasteboard.pasteboardItems?
            .reduce(into: [Content]()) { result, item in
                result.append(
                    contentsOf: item.types.map { Content(type: $0, value: item.data(forType: $0)) }
                )
            } ?? []
    }

    var description: String {

        """
        (\(id)). Contents: '\(contents.count)'
        Types: \(contents.map { $0.type.rawValue })
        Values: \(contents.map { String(data: $0.value ?? Data(), encoding: .utf8) } )
        """
    }
}

extension Paste {

    struct Content {
        let type: NSPasteboard.PasteboardType
        let value: Data?
    }
}
