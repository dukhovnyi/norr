//
//  SettingsView.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 16.05.2023.
//

import SwiftUI

struct SettingsView: View {

    @StateObject var model: Model

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            RetentionDataSettingsView(wipe: model.wipe)
                .tabItem {
                    Label("Retention Data", systemImage: "folder.badge.gearshape")
                }
                .tag(Tabs.retentionData)
        }
        .padding(20)
    }
}

extension SettingsView {

    private enum Tabs: Hashable {
        case general, retentionData
    }

    final class Model: ObservableObject {

        let wipe: () -> Void

        init(wipe: @escaping () -> Void) {
            self.wipe = wipe
        }
    }
}

struct GeneralSettingsView: View {

    var body: some View {
        VStack(alignment: .leading) {
            LaunchAtLoginView()
            SettingsShortcutView()

            Text("Version: \(Bundle.main.semver)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(width: 420, height: 100)
    }
}

struct PrefsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: .init(wipe: {}))
    }
}
