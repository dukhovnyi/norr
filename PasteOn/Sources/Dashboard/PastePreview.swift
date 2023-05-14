//
//  PastePreview.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 03.03.2023.
//

import SwiftUI

struct PastePreview: View {

    @State var paste: Paste
    @State var onHover = false

    let onRemove: () -> Void
    let pin: () -> Void
    let unpin: () -> Void

    var body: some View {
        HStack {

            switch Paste.PreviewType(contents: paste.contents) {

            case .plainText(let text):
                Text(text.prefix(140))
                    .padding(4)

            case .richText(let attributedString):
                Text(attributedString)
                    .padding()
                    .ifLet(attributedString.backgroundColor?.cgColor) { view, cgColor in
                        view.background(Color(cgColor: cgColor))
                    }

            case .color(let color):
                HStack {
                    Text("   ")
                        .padding(3)
                        .background(Color(color))
                    Text("red: \(color.redComponent) green: \(color.greenComponent) blue: \(color.blueComponent) hex: \(color.toHex() ?? "")")
                }

            case .png(let imageData):
                if let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 240)
                } else {
                    Text("Image")
                }

            case .fileUrl(let url):
                Text(url.absoluteString)

            case .url(let url):
                Text(url.absoluteString)
            }

            Spacer()
            appIcon()
            if paste.isBolted {
                Button(
                    action: unpin,
                    label: { Text("\(paste.isBolted.description)") /*Image(systemName: "pin")*/ }
                )
            } else {
                Button(
                    action: pin,
                    label: { Text("\(paste.isBolted.description)") /* Image(systemName: "pin.fill") */ }
                )
            }

            Button(
                action: onRemove,
                label: { Image(systemName: "trash") }
            )
        }
        .frame(maxWidth: .infinity)
//        .overlay(alignment: .trailing) {
//            HStack(spacing: 16) {
//                appIcon()
//                Button(
//                    action: { paste.pinned ? unpin() : pin() },
//                    label: { Image(systemName: paste.pinned ? "pin.fill" : "pin") }
//                )
//                Button(
//                    action: onRemove,
//                    label: { Image(systemName: "trash") }
//                )
//            }
//
//            .padding(.horizontal, 8)
//            .buttonStyle(.borderless)
//            .opacity(onHover ? 0.8 : 0)
//            .background(Color.gray.opacity(onHover ? 0.1 : 0))
//            .cornerRadius(6)
//        }
//        .onHover { isHover in
//            withAnimation {
//                onHover = isHover
//            }
//        }
    }

    @ViewBuilder func appIcon() -> some View {
        if let path = paste.bundleUrl?.path {
            Image(nsImage: NSWorkspace.shared.icon(forFile: path))
                .resizable()
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: "camera.metering.unknown")
        }
    }
}

struct PastePreview_Previews: PreviewProvider {

    static var previews: some View {
        List {

            PastePreview(
                paste: .init(
                    id: .init(),
                    changeCount: 1,
                    createdAt: .now,
                    pasteboardItems: [.plainText(.loremIpsum)],
                    bundleUrl: .init(string: "/Applications/Xcode.app"),
                    isBolted: false
                ),
                onHover: true,
                onRemove: {},
                pin: {},
                unpin: {}
            )

            PastePreview(
                paste: .init(
                    id: .init(),
                    changeCount: 2,
                    createdAt: .now,
                    pasteboardItems: [.color(.red)],
                    bundleUrl: .init(string: "/Applications/Pages.app"),
                    isBolted: false
                ),
                onRemove: {},
                pin: {},
                unpin: {}
            )

            PastePreview(
                paste: .init(
                    id: .init(),
                    changeCount: 2,
                    createdAt: .now,
                    pasteboardItems: [.url(.init(string: "https://www.dukhovnyi.com")!)],
                    bundleUrl: .init(string: "/Applications/Slack.app"),
                    isBolted: true
                ),
                onHover: true,
                onRemove: {},
                pin: {},
                unpin: {}
            )

            PastePreview(
                paste: .init(
                    id: .init(),
                    changeCount: 3,
                    createdAt: .now,
                    pasteboardItems: [.rtf("{\\rtf1\\ansi\\ansicpg1252\\cocoartf2708\n\\cocoatextscaling0\\cocoaplatform0{\\fonttbl\\f0\\fnil\\fcharset0 JetBrainsMono-ExtraLight;\\f1\\fnil\\fcharset0 JetBrainsMono-Medium;}\n{\\colortbl;\\red255\\green255\\blue255;\\red108\\green121\\blue134;\\red31\\green31\\blue36;\\red255\\green255\\blue255;\n}\n{\\*\\expandedcolortbl;;\\csgenericrgb\\c42394\\c47462\\c52518;\\csgenericrgb\\c12054\\c12284\\c14131;\\csgenericrgb\\c100000\\c100000\\c100000\\c85000;\n}\n\\deftab624\n\\pard\\tx624\\pardeftab624\\pardirnatural\\partightenfactor0\n\n\\f0\\fs26 \\cf2 \\cb3 //\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //  Paste+PreviewType.swift\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //  Pasteboard\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //  Created by Yurii Dukhovnyi on 19.02.2023.\n\\f1 \\cf4 \\\n\n\\f0 \\cf2 //}")],
                    bundleUrl: .init(string: "/Applications/Slack.app"),
                    isBolted: true
                ),
                onHover: true,
                onRemove: {},
                pin: {},
                unpin: {}
            )
        }
        .frame(width: 700, height: 400)
    }
}

extension Data {
    static let icon: Data = {
        NSImage(named: "statusbar-icon")?.tiffRepresentation ?? Data()
    }()
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
