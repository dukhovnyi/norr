//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

extension ItemInfoView {

    struct ColorSection: View {
    
        let hex: String
        let rgb: String
        let alpha: String

        var body: some View {
            Section("More") {
                ItemInfoView.Row(title: "Hex", value: hex)
                ItemInfoView.Row(title: "RGB", value: rgb)
                ItemInfoView.Row(title: "Alpha", value: alpha)
            }
        }

        init?(paste: Paste) {

            guard let content = paste.representations.first(where: { $0.type == .color }) else {
                return nil
            }

            let nsColor = content.data?.getPasteboardColor() ?? .clear

            hex = "#\(nsColor.toHex() ?? "")"
            rgb = "\(Int(nsColor.redComponent)) \(Int(nsColor.greenComponent)) \(Int(nsColor.blueComponent))"
            alpha = "\(Int(nsColor.alphaComponent) * 100)%"
        }
    }

}

#Preview {
    ItemInfoView.ColorSection(
        paste: .mockColor()
    )
}
