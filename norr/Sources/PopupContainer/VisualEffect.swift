//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import SwiftUI

struct VisualEffect: NSViewRepresentable {

    func makeNSView(context: Self.Context) -> NSView {
        NSVisualEffectView()
    }

    func updateNSView(_ nsView: NSView,context: Context) {}
}
