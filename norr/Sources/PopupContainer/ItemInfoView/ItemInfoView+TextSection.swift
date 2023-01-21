//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

extension ItemInfoView {

    struct TextSection: View {
        
        let lines: String
        let words: String
        let chars: String

        var body: some View {
            Section("More") {
                ItemInfoView.Row(title: "Lines", value: lines)
                ItemInfoView.Row(title: "Words", value: words)
                ItemInfoView.Row(title: "Characters", value: chars)
            }
        }

        init?(paste: Paste) {

            guard 
                let data = paste.representations.first(where: { $0.type == .string })?.data
            else {
                return nil
            }
            let stringRepresentation = String(decoding: data, as: UTF8.self)
            lines = "\(stringRepresentation.components(separatedBy: .newlines).count)"
            words = "\(stringRepresentation.components(separatedBy: .whitespacesAndNewlines).count)"
            chars = "\(stringRepresentation.count)"
        }

    }

}

#Preview {
    VStack {
        ItemInfoView.TextSection(paste: .mockRtf())
        ItemInfoView.TextSection(paste: .mockPlainText())
    }
}
