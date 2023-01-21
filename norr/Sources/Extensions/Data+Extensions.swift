//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit

extension Data {

    func getPasteboardColor() -> NSColor? {
        do {
            guard let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: self) else {
                debugPrint("🔥 NSColor can't be created from proertyList data.")
                return nil
            }

            // After reading from pasteboard NSColor has incorrect cgColor components.
            // To avoid this issue we need to recreate NSColor with main initializer.
            return NSColor(
                cgColor: .init(
                    red: nsColor.redComponent / 255,
                    green: nsColor.greenComponent / 255,
                    blue: nsColor.blueComponent / 255,
                    alpha: nsColor.alphaComponent
                )
            )


        } catch {
            return nil
        }
    }
}
