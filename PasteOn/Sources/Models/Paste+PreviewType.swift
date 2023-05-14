//
//  Paste+PreviewType.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 19.02.2023.
//

import AppKit
import Foundation

extension Paste {

    enum PreviewType {
        case plainText(String)
        case richText(AttributedString)
        case color(NSColor)
        case png(Data)
        case fileUrl(URL)
        case url(URL)

        init(contents: [Paste.Content]) {

            if let rtfConetnt = Self.handleRtfContent(contents: contents) {
                self = .richText(rtfConetnt)
            } else if let color = Self.handleColorContent(contents: contents) {
                self = .color(color)
            } else if let pngContents = contents.first(where: { $0.type == .png }), let pngData = pngContents.value {
                self = .png(pngData)
            } else if let fileUrl = Self.handleUrlContent(contents: contents, type: .fileURL) {
                self = .fileUrl(fileUrl)
            } else if let url = Self.handleUrlContent(contents: contents, type: .URL) {
                self = .url(url)
            } else {
                let stringContent = contents.first(where: { $0.type == .string })
                self = .plainText(String(decoding: stringContent?.value ?? Data(), as: UTF8.self))
            }
        }

        static func handleRtfContent(
            contents: [Paste.Content]
        ) -> AttributedString? {

            guard let rtf = contents.first(where: { $0.type == .rtf  || $0.type == .rtfd }) else {
                return nil
            }

            guard let data = rtf.value else {
                debugPrint("Rtf content has no 'data'.")
                return nil
            }

            do {

                let nsAttributedString = try NSAttributedString(
                    data: data,
                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                    documentAttributes: nil
                )
                var attributedString = AttributedString(nsAttributedString)
                if let color = nsAttributedString.attribute(.backgroundColor, at: 0, effectiveRange: nil) as? NSColor {
                    attributedString.backgroundColor = .init(nsColor: color)
                }
                return attributedString

            } catch {

                debugPrint("🔥 NSAttributredString has not been created from Rtf data. Error='\(error)'.")
                return nil
            }
        }

        static func handleColorContent(
            contents: [Paste.Content]
        ) -> NSColor? {

            guard let colorContent = contents.first(where: { $0.type == .color }) else {
                return nil
            }

            guard let data = colorContent.value else {
                debugPrint("🔥 Color content has no 'data'.")
                return nil
            }

//            guard let nsColor = NSColor(pasteboardPropertyList: data, ofType: .color) else {
//                debugPrint("🔥 NSColor can't be created from proertyList data.")
//                return nil
//            }

            do {
                guard let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
                    debugPrint("🔥 NSColor can't be created from proertyList data.")
                    return nil
                }
                // After reading from pasteboard NSColor has incorrect cgColor components.
                // To avoid this issue we need to recreate NSColor with main initializer.
                return NSColor(
                    cgColor: .init(
                        red: nsColor.redComponent / 255,
                        green: nsColor.greenComponent / 255,
                        blue: nsColor.blueComponent / 255,
                        alpha: nsColor.alphaComponent
                    )
                )


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

extension Paste.PreviewType: Hashable {

    func hash(into hasher: inout Hasher) {
        switch self {
        case .plainText(let value):
            hasher.combine(value)
        case .richText(let attributedString):
            hasher.combine(attributedString)
        case .color(let value):
            hasher.combine(value)
        case .png(let data):
            hasher.combine(data)
        case .fileUrl(let url):
            hasher.combine(url)
        case .url(let url):
            hasher.combine(url)
        }
    }
}
