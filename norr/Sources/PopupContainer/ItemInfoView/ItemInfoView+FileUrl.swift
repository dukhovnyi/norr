//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

extension ItemInfoView {

    struct FileUrlSection: View {
        
        let path: String
        let size: String

        var body: some View {
            
            Section("More") {
                ItemInfoView.Row(title: "Path", value: path)
                    .multilineTextAlignment(.trailing)
                ItemInfoView.Row(title: "File size", value: size)
            }

        }

        init?(paste: Paste, byteFormatter: ByteCountFormatter) {
            guard
                let contentData = paste.representations.first(where: { $0.type == .fileURL })?.data,
               let fileUrl = URL(dataRepresentation: contentData, relativeTo: nil),
               let path = fileUrl.standardizedFileURL.path().removingPercentEncoding
            else {
                return nil
            }
            self.path = path
            self.size = Self.formattedBytes(path, byteFormatter: byteFormatter)
        }

        static func formattedBytes(_ path: String, byteFormatter: ByteCountFormatter) -> String {

            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                let value = attributes[.size] as? Int ?? 0
                let measurement = Measurement<UnitInformationStorage>(value: Double(value), unit: .bytes)
                return byteFormatter.string(from: measurement)
            } catch {
                debugPrint("💥 File size has not been retrieved. Error='\(error)'.")
                return "-"
            }
        }
    }

}

#Preview {
    ItemInfoView.FileUrlSection(
        paste: .mockFileUrl(),
        byteFormatter: .init()
    )
}
