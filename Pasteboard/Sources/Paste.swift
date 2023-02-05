//
//  Paste.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit

struct Paste: Equatable, Identifiable, Hashable, CustomStringConvertible {

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

    var stringRepresentation: String {

        if let data = contents.first(where: { $0.type == .string })?.value {
            return String(decoding: data, as: UTF8.self)
        }

        if let _ = contents.first(where: { $0.type == .png })?.value {
            return "png image"
        }

        let msg = String(decoding: contents.first?.value ?? .init(), as: UTF8.self)
//        assertionFailure("unknown contents='\(msg)'.")

        return msg.isEmpty ? contents.map { "\($0.type)" }.joined() : msg
    }
}

extension Paste {

    struct Content: Hashable {
        let type: NSPasteboard.PasteboardType
        let value: Data?
    }
}

extension Paste: Comparable {
    static func < (lhs: Paste, rhs: Paste) -> Bool {
        lhs.id < rhs.id
    }
}
