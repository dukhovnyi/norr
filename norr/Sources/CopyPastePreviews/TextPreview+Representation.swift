//
//  TextPreview+Representation.swift
//  norr
//
//  Created by Yurii Dukhovnyi on 08.06.2023.
//

import AppKit
import Foundation

extension TextPreview {

    struct Representation {
        let value: String

        init(contents: [Paste.Content]) {

            if let color = Self.handleColorContent(contents: contents) {
                self.value = color
            } else if let pngContents = contents.first(where: { $0.type == .png }), let pngData = pngContents.value {
                let formatter = ByteCountFormatter()
                self.value = "image: \(formatter.string(fromByteCount: Int64(pngData.count)))"
            } else if let fileUrl = Self.handleUrlContent(contents: contents, type: .fileURL) {
                self.value = fileUrl.standardizedFileURL.absoluteString
            } else if let url = Self.handleUrlContent(contents: contents, type: .URL) {
                self.value = url.absoluteString
            } else {
                let stringContent = contents.first(where: { $0.type == .string })
                if let data = stringContent?.value {
                    self.value = String(decoding: data, as: UTF8.self)
                } else {
                    self.value = "* This object has no text representation *"
                }
            }
        }

        static func handleColorContent(contents: [Paste.Content]) -> String? {

            guard let colorContent = contents.first(where: { $0.type == .color }) else {
                return nil
            }

            guard let data = colorContent.value else {
                debugPrint("🔥 Color content has no 'data'.")
                return nil
            }

            do {
                guard let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
                    debugPrint("🔥 NSColor can't be created from proertyList data.")
                    return nil
                }

                return "\(nsColor.toHex() ?? "#??????") \(nsColor.redComponent) \(nsColor.greenComponent) \(nsColor.blueComponent) \(nsColor.alphaComponent)"

            } catch {
                return nil
            }
        }

        static func handleUrlContent(
            contents: [Paste.Content],
            type: NSPasteboard.PasteboardType
        ) -> URL? {

            guard let urlContent = contents.first(where: { $0.type == type }) else {
                return nil
            }

            guard let data = urlContent.value else {
                debugPrint("🔥 \(type.rawValue.capitalized) content has no 'data'.")
                return nil
            }

            return URL(dataRepresentation: data, relativeTo: nil)
        }
    }


}
