//
//  LaunchAtLoginView.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 17.05.2023.
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
