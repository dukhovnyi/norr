//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import RealmSwift

final class Paste: Object, Identifiable {

    /// Unique identifier.
    ///
    @Persisted(primaryKey: true) var id: String

    /// Pasteboard change count. This counter is changing each copying.
    ///
    @Persisted var changeCount: Int

    /// Added to Norr application history. This date may be different with date when
    ///  copying happen in file system.
    ///
    @Persisted var createdAt: Date

    /// Content representations. See `Paste.Representation`.
    ///
    @Persisted var representations: List<PasteRepresentation>

    /// Bundle identifier of the application that has been active during copying.
    ///
    @Persisted var bundleId: String?

    convenience init(
        id: String,
        changeCount: Int,
        createdAt: Date,
        representations: List<PasteRepresentation>,
        bundleId: String?
    ) {
        self.init()

        self.id = id
        self.changeCount = changeCount
        self.createdAt = createdAt
        self.representations = representations
        self.bundleId = bundleId
    }

    convenience init(
        id: String,
        changeCount: Int,
        createdAt: Date,
        pasteboardItems: [NSPasteboardItem],
        bundleId: String?
    ) {
        let representations = pasteboardItems
            .reduce(into: List<PasteRepresentation>()) { result, item in
                result.append(
                    objectsIn: item.types.map { PasteRepresentation(type: $0, data: item.data(forType: $0)) }
                )
            }

        self.init(
            id: id,
            changeCount: changeCount,
            createdAt: createdAt,
            representations: representations,
            bundleId: bundleId
        )
    }

    var stringRepresentation: String {

        if let data = representations.first(where: { $0.type == .string })?.data {
            return String(decoding: data, as: UTF8.self)
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .joined(separator: "\n")
        }

        if let data = representations.first(where: { $0.type == .png })?.data {
            var message = "Image"
            if let size = NSImage(data: data)?.size {
                message.append(" \(Int(size.width))x\(Int(size.height)) px")
            }
            return message

        }

        let msg = String(decoding: representations.first?.data ?? .init(), as: UTF8.self)
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: "\n")

        return msg.isEmpty ? representations.map { "\($0.type)" }.joined() : msg
    }

    func `is`(_ expectedType: NSPasteboard.PasteboardType) -> Bool {
        representations.contains(where: { $0.type == expectedType })
    }
}

/// Defines pasteboard item representation.
final class PasteRepresentation: Object {
    /// Pasteboard item type.
    var type: NSPasteboard.PasteboardType { .init(typeRawValue) }

    @Persisted var typeRawValue: String

    /// Pasteboard item raw data.
    @Persisted var data: Data?

    convenience init(type: NSPasteboard.PasteboardType, data: Data?) {
        self.init()
        self.typeRawValue = type.rawValue
        self.data = data
    }
}
