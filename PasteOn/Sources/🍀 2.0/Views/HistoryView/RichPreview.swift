//
//  RichPreview.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import SwiftUI

struct RichPreview: View {

    @StateObject var model: Model

    var body: some View {
        HStack {

            switch model.preview {
                case .plainText(let text):
                    Text(text.prefix(140))
                        .padding(4)

                case .richText(let attributedString):
                    Text(attributedString)
                        .truncationMode(.tail)
                        .lineLimit(2)
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
        }
        .frame(maxWidth: .infinity)
    }
}

struct HistoryItem_Previews: PreviewProvider {
    static var previews: some View {
        RichPreview(
            model: .init(paste: .mockRtf())
        )
    }
}

extension RichPreview {

    final class Model: ObservableObject {

        @Published var preview: Paste.PreviewType

        init(paste: Paste) {
            self.preview = .init(contents: paste.contents)
        }
    }
}
