//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

struct AppIcon: View {

    let bundleId: String?
    let size: CGSize

    var body: some View {
        if let bundleId,
           let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)?.path {

            Image(nsImage: NSWorkspace.shared.icon(forFile: path))
                .resizable()
                .frame(width: size.width, height: size.height)
        } else {
            Image(systemName: "camera.metering.unknown")
                .frame(width: size.width, height: size.height)
        }
    }
}

#Preview {
    HStack {
        AppIcon(bundleId: "com.apple.dt.Xcode", size: .init(width: 80, height: 80))
        AppIcon(bundleId: "com.spotify.client", size: .init(width: 80, height: 80))
        AppIcon(bundleId: "unknown.app", size: .init(width: 80, height: 80))
    }
}
