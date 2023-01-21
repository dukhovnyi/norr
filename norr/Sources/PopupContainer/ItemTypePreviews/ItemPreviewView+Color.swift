//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

extension ItemPreviewView {

    struct ColorRef: View {

        let nsColor: NSColor

        var body: some View {
            ZStack {
                Color(nsColor: nsColor)

                Text(paste.stringRepresentation.prefix(6))
                    .font(.system(size: 18, weight: .thin))
                    .foregroundStyle(Color(hex: "#ffffff"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#5b5b5b"))
                    .background(in: .capsule)
            }
        }

        init?(paste: Paste) {
            guard
                let content = paste.representations.first(where: { $0.type == .color && $0.data != nil })
            else {
                return nil
            }
            self.paste = paste
            self.nsColor = content.data?.getPasteboardColor() ?? .clear
        }

        // MARK: - Private

        private let paste: Paste
    }

}

#Preview {
    ItemPreviewView.ColorRef(paste: .mockColor())
}
