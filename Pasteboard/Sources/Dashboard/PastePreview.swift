//
//  PastePreview.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 03.03.2023.
//

import SwiftUI

struct PastePreview: View {

    let bundleUrl: URL?
    @State var type: Paste.PreviewType

    var body: some View {
        switch type {

        case .plainText(let text):
            ZStack(alignment: .leading) {
                Text(text)
                badge("Plain Text")
            }

        case .richText(let attributedString):
            Text(attributedString)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ifLet(attributedString.backgroundColor?.cgColor) { view, cgColor in
                    view.background(Color(cgColor: cgColor))
                }
                .overlay {
                    badge("Rich Text")
                }

        case .color(let color):
            ZStack(alignment: .leading) {

                HStack {
                    Text("   ")
                        .padding(3)
                        .background(Color(color))
                    Text("red: \(color.redComponent) green: \(color.greenComponent) blue: \(color.blueComponent) hex: \(color.toHex() ?? "")")
                }

                badge("Color")
            }

        case .png(let imageData):
            ZStack {
                if let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 240)
                } else {
                    Text("Image")
                }

                badge("Image")
            }

        case .fileUrl(let url):
            ZStack(alignment: .leading) {
                Text(url.absoluteString)

                badge("File URL")
            }

        case .url(let url):
            ZStack(alignment: .leading) {
                Text(url.absoluteString)

                badge("URL")
            }
        }
    }

    @ViewBuilder func badge(
        _ text: String
    ) -> some View {
        HStack(alignment: .bottom) {
            Spacer()
            if let path = bundleUrl?.path(), let icon = NSWorkspace.shared.icon(forFile: path) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
            } else {
                Text(text)
                    .font(.footnote)
                    .bold()
            }
        }
        .opacity(0.3)
    }
}

struct PastePreview_Previews: PreviewProvider {

    static var previews: some View {
        VStack {

            PastePreview(
                bundleUrl: nil,
                type: .plainText(.loremIpsum)
            )

            PastePreview(
                bundleUrl: nil,
                type: .richText(.loremIpsum)
            )

            PastePreview(
                bundleUrl: nil,
                type: .color(.yellow)
            )

            PastePreview(
                bundleUrl: nil,
                type: .png(.icon)
            )

            PastePreview(
                bundleUrl: nil,
                type: .fileUrl(URL(string: "file://Users/pasteboard/Developer/")!)
            )

            PastePreview(
                bundleUrl: nil,
                type: .fileUrl(URL(string: "https://www.pasteboard-app.com")!)
            )
        }
        .padding()
    }
}

extension Data {
    static let icon: Data = {
        NSImage(named: "statusbar-icon")?.tiffRepresentation ?? Data()
    }()
}
