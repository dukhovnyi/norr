//
//  Paste+Mock.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import AppKit

extension Paste {

    static func mockPlainText(text: String = .loremIpsum) -> Self {
        .init(
            id: .init(),
            changeCount: 1,
            createdAt: .now,
            pasteboardItems: [.plainText(text)],
            bundleId: nil,
            isBolted: false
        )
    }

    static func mockColor(color: NSColor = .red) -> Self {
        .init(
            id: .init(),
            changeCount: 2,
            createdAt: .now,
            pasteboardItems: [.color(color)],
            bundleId: nil,
            isBolted: false
        )
    }

    static func mockUrl(url: URL = .init(string: "https://www.dukhovnyi.com")!) -> Self {
        .init(
            id: .init(),
            changeCount: 2,
            createdAt: .now,
            pasteboardItems: [.url(url)],
            bundleId: nil,
            isBolted: true
        )
    }

    static func mockRtf() -> Self {
        .init(
            id: .init(),
            changeCount: 3,
            createdAt: .now,
            pasteboardItems: [.rtf("{\\rtf1\\ansi\\ansicpg1252\\cocoartf2708\n\\cocoatextscaling0\\cocoaplatform0{\\fonttbl\\f0\\fnil\\fcharset0 JetBrainsMono-ExtraLight;\\f1\\fnil\\fcharset0 JetBrainsMono-Medium;}\n{\\colortbl;\\red255\\green255\\blue255;\\red108\\green121\\blue134;\\red31\\green31\\blue36;\\red255\\green255\\blue255;\n}\n{\\*\\expandedcolortbl;;\\csgenericrgb\\c42394\\c47462\\c52518;\\csgenericrgb\\c12054\\c12284\\c14131;\\csgenericrgb\\c100000\\c100000\\c100000\\c85000;\n}\n\\deftab624\n\\pard\\tx624\\pardeftab624\\pardirnatural\\partightenfactor0\n\n\\f0\\fs26 \\cf2 \\cb3 //\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //  Paste+PreviewType.swift\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //  Pasteboard\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //  Created by Yurii Dukhovnyi on 19.02.2023.\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //}")],
            bundleId: nil,
            isBolted: true
        )
    }
}

extension NSPasteboardItem {

    static func plainText(_ str: String) -> Self {
        let item = Self()
        item.setString(str, forType: .string)
        return item
    }

    static func color(_ color: NSColor) -> Self {
        let item = Self()
        let color = try! NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        item.setData(color, forType: .color)
        return item
    }

    static func url(_ url: URL) -> Self {
        let item = Self()
        item.setData(url.dataRepresentation, forType: .URL)
        return item
    }

    static func rtf(_ rawData: String) -> Self {
        let item = Self()
        item.setData(Data(rawData.utf8), forType: .rtf)
        return item
    }
}
