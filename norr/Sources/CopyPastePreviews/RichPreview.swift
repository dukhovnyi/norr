//
//  RichPreview.swift
//  noor
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

extension View {

    @ViewBuilder func ifLet<Transform: View, V>(
        _ condition: @autoclosure () -> V?,
        @ViewBuilder transform: (Self, V) -> Transform
    ) -> some View {

        if let result = condition() {
            transform(self, result)
        } else {
            self
        }
    }

    @ViewBuilder func ifCondition(
        _ condition: @autoclosure () -> Bool,
        @ViewBuilder transform: (Self) -> some View
    ) -> some View {

        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

extension NSColor {
    convenience init(hex: String) {
        let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
        let ui64 = UInt64(hexString, radix: 16)
        let value = ui64 != nil ? Int(ui64!) : 0
        // #RRGGBB
        var components = (
            R: CGFloat((value >> 16) & 0xff) / 255,
            G: CGFloat((value >> 08) & 0xff) / 255,
            B: CGFloat((value >> 00) & 0xff) / 255,
            a: CGFloat(1)
        )
        if String(hexString).count == 8 {
            // #RRGGBBAA
            components = (
                R: CGFloat((value >> 24) & 0xff) / 255,
                G: CGFloat((value >> 16) & 0xff) / 255,
                B: CGFloat((value >> 08) & 0xff) / 255,
                a: CGFloat((value >> 00) & 0xff) / 255
            )
        }
        self.init(red: components.R, green: components.G, blue: components.B, alpha: components.a)
    }

    func toHex(alpha: Bool = false) -> String? {

        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
