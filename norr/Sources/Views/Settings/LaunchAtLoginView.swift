//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import LaunchAtLogin
import SwiftUI

struct LaunchAtLoginView: View {
    var body: some View {
        LaunchAtLogin.Toggle(
            label: {
                Text("Launch at login")
            }
        )
    }
}

struct LaunchAtLoginView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchAtLoginView()
    }
}
