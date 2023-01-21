//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit

extension Paste {

    static func mockPlainText(
        text: String = .loremIpsum,
        uuid: UUID = .init(uuidString: "B1D29532-3689-428E-B1BB-B44BA56FDEBA")!
    ) -> Self {
        .init(
            id: uuid.uuidString,
            changeCount: 1,
            createdAt: .now,
            pasteboardItems: [.plainText(text)],
            bundleId: "com.apple.SFSymbols-beta"
        )
    }

    static func mockColor(
        color: NSColor = .red,
        uuid: UUID = .init(uuidString: "B1D29532-3689-428E-B1BB-B44BA56FDEBA")!
    ) -> Self {
        .init(
            id: uuid.uuidString,
            changeCount: 2,
            createdAt: .now,
            pasteboardItems: [.color(color)],
            bundleId: "com.apple.DigitalColorMeter"
        )
    }

    static func mockUrl(
        url: URL = .init(string: "https://www.dukhovnyi.com")!,
        uuid: UUID = .init(uuidString: "B1D29532-3689-428E-B1BB-B44BA56FDEBA")!
    ) -> Self {
        .init(
            id: uuid.uuidString,
            changeCount: 2,
            createdAt: .now,
            pasteboardItems: [.url(url)],
            bundleId: "com.apple.dt.Xcode"
        )
    }

    static func mockFileUrl(
        fileUrl: URL = .init(string: "/System/Applications/App Store.app/Contents/Info.plist")!,
        uuid: UUID = .init(uuidString: "B5BE4F1F-9E59-42BC-BB98-E1BC43F49E50")!
    ) -> Self {
        .init(
            id: uuid.uuidString,
            changeCount: 4,
            createdAt: .now,
            pasteboardItems: [.fileUrl(fileUrl)],
            bundleId: "com.apple.dt.Xcode"
        )
    }

    static func mockRtf(
        uuid: UUID = .init(uuidString: "B1D29532-3689-428E-B1BB-B44BA56FDEBA")!
    ) -> Self {
        .init(
            id: uuid.uuidString,
            changeCount: 3,
            createdAt: .now,
            pasteboardItems: [.rtf("{\\rtf1\\ansi\\ansicpg1252\\cocoartf2709\n\\cocoatextscaling0\\cocoaplatform0{\\fonttbl\\f0\\fnil\\fcharset0 JetBrainsMono-ExtraLight;\\f1\\fnil\\fcharset0 JetBrainsMono-Medium;}\n{\\colortbl;\\red255\\green255\\blue255;\\red108\\green121\\blue134;\\red31\\green31\\blue36;\\red255\\green255\\blue255;\n}\n{\\*\\expandedcolortbl;;\\csgenericrgb\\c42394\\c47462\\c52518;\\csgenericrgb\\c12054\\c12284\\c14131;\\csgenericrgb\\c100000\\c100000\\c100000\\c85000;\n}\n\\deftab576\n\\pard\\tx576\\pardeftab576\\partightenfactor0\n\n\\f0\\fs24 \\cf2 \\cb3 //\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 // This is Rich Text Preview\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 // by Norr\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //}")],
            bundleId: nil
        )
    }

    static func mockImage(
        uuid: UUID = .init(uuidString: "3B12D24F-04C7-4ADF-8AE0-E55EAD071A35")!
    ) -> Self {
            .init(
                id: uuid.uuidString,
                changeCount: 4,
                createdAt: .now,
                pasteboardItems: [.image()],
                bundleId: "com.apple.dt.Xcode"
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

    static func fileUrl(_ url: URL) -> Self {
        let item = Self()
        item.setData(url.dataRepresentation, forType: .fileURL)
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

    static func image() -> Self {
        let item = Self()
        if let fileUrl = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
            let icns = try? Data(contentsOf: fileUrl) {
            item.setData(icns, forType: .png)
        }
        return item
    }
}
