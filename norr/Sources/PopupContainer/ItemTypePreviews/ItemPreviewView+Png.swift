//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import SwiftUI

extension ItemPreviewView {

    struct Png: View {

        let nsImage: NSImage

        var body: some View {
            Image(nsImage: nsImage)
                .resizable(resizingMode: .stretch)
                .scaledToFit()
        }

        init?(paste: Paste) {
            guard
                let content = paste.representations.first(where: { $0.type == .png && $0.data != nil })
            else {
                return nil
            }

            self.nsImage = .init(data: content.data ?? .init()) ?? .init()
        }
    }

}

#Preview {
    ItemPreviewView.Png(paste: .mockImage())
}
