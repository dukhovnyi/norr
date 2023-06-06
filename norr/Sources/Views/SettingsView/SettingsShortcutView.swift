//
//  SettingsShortcutView.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 17.05.2023.
//

import KeyboardShortcuts
import SwiftUI

struct SettingsShortcutView: View {
    var body: some View {
        KeyboardShortcuts.Recorder(
            "Global shortcut for quick access the app",
            name: .pasteboard
        )
    }
}

struct SettingsShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsShortcutView()
    }
}
