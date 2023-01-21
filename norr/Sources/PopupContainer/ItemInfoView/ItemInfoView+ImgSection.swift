//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

extension ItemInfoView {

    struct ImgSection: View {

        var storageSize: String = "N/A"
        var imageSize: String = "N/A"
        @State var quicklookupUrl: URL?

        var body: some View {
            Section("More") {
                ItemInfoView.Row(title: "File size", value: storageSize)
                ItemInfoView.Row(title: "Image size", value: imageSize)
            }
        }

        init?(
            paste: Paste,
            byteFormatter: ByteCountFormatter
        ) {

            guard
                let content = paste.representations.first(where: { $0.type == .png })
            else { return nil }
            self.paste = paste
            let measurement = Measurement<UnitInformationStorage>(
                value: Double(content.data?.count ?? 0),
                unit: .bytes
            )
            let img = NSImage(data: content.data ?? .init())
            let size = img?.size
            storageSize = byteFormatter.string(from: measurement)
            if let size {
                imageSize = "\(Int(size.width)) x \(Int(size.height))"
            }
        }

        // MARK: - Private

        private let paste: Paste

        private static func byteFormatter() -> ByteCountFormatter {
            let bf = ByteCountFormatter()
            bf.countStyle = .decimal
            return bf
        }
    }

}
#Preview {
    ItemInfoView.ImgSection(paste: .mockImage(), byteFormatter: .init())
}

extension ItemInfoView {

    struct Row: View {
        
        let title: String
        let value: String

        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Text(value)
            }
        }
    }
}
