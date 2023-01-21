//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import KeyboardShortcuts
import SwiftUI

struct SettingsShortcutView: View {
    var body: some View {
        KeyboardShortcuts.Recorder(
            "Global shortcut for quick access the app",
            name: .norr
        )
    }
}

struct SettingsShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsShortcutView()
    }
}
