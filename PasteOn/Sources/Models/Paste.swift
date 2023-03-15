//
//  Paste.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 22.01.2023.
//

import AppKit

struct Paste: Equatable, Identifiable, Hashable, CustomStringConvertible {

    /// Unique identifier.
    let id: String
    /// Pasteboard change count.
    let changeCount: Int
    /// Created in the app history. This is not a time when it has been placed into
    ///  pasteboard.
    let createdAt: Date
    /// Paste contents and representations.
    let contents: [Content]

    let bundleUrl: URL?

    init(
        id: String,
        changeCount: Int,
        createdAt: Date,
        contents: [Paste.Content],
        bundleUrl: URL?
    ) {
        self.id = id
        self.changeCount = changeCount
        self.createdAt = createdAt
        self.contents = contents
        self.bundleUrl = bundleUrl
    }

    init(
        id: UUID,
        changeCount: Int,
        createdAt: Date,
        pasteboardItems: [NSPasteboardItem],
        bundleUrl: URL?
    ) {
        let contents = pasteboardItems
            .reduce(into: [Content]()) { result, item in
                result.append(
                    contentsOf: item.types.map { Content(type: $0, value: item.data(forType: $0)) }
                )
            }

        self.init(
            id: id.uuidString,
            changeCount: changeCount,
            createdAt: createdAt,
            contents: contents,
            bundleUrl: bundleUrl
        )
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
