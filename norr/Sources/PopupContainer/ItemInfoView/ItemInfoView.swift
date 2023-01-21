//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

struct ItemInfoView: View {

    let paste: Paste

    var body: some View {
        List {
            //            #if DEBUG
            //            Text(paste.contents.first?.type.rawValue ?? "")
            //            #endif
            Section("Info") {
                HStack {
                    Text("Application:")
                    Spacer()
                    HStack {
                        AppIcon(
                            bundleId: paste.bundleId,
                            size: .init(width: 18, height: 18)
                        )
                        Text(appName(for: paste.bundleId ?? "N/A"))
                    }
                }

                HStack {
                    Text("Created at:")
                    Spacer()
                    Text(formattedDate(paste.createdAt))
                }
            }

            if paste.representations.contains(where: { $0.type == .png }) {
                ImgSection(paste: paste, byteFormatter: byteFormatter)
            } else if paste.representations.contains(where: { $0.type == .color }) {
                ColorSection(paste: paste)
            } else if paste.representations.contains(where: { $0.type == .fileURL }) {
                FileUrlSection(paste: paste, byteFormatter: byteFormatter)
            } else if paste.representations.contains(where: { $0.type == .rtf || $0.type == .rtfd || $0.type == .string }) {
                TextSection(paste: paste)
            }

        }
    }



    func appName(for bundleId: String) -> String {
        let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
        guard let url else { return bundleId}

        return Bundle(url: url)?.name ?? bundleId
    }

    func formattedDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    // MARK: - Private

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        df.dateStyle = .short
        return df
    }()

    private let byteFormatter: ByteCountFormatter = {
        let bf = ByteCountFormatter()
        bf.countStyle = .decimal
        return bf
    }()
}

#Preview {
    VStack {
        ItemInfoView(paste: .mockImage())
        ItemInfoView(paste: .mockPlainText())
        ItemInfoView(paste: .mockColor())
        ItemInfoView(paste: .mockRtf())
        ItemInfoView(paste: .mockPlainText())
    }
    .frame(height: 1200)
}

