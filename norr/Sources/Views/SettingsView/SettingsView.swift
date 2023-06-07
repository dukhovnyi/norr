//
//  SettingsView.swift
//  noor
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
            ExcludeAppsView(model: .init(excludeApps: model.engine.excludeApps))
                .tabItem {
                    Label("Exclude Apps", systemImage: "line.3.horizontal.decrease.circle")
                }
                .tag(Tabs.ignore)
            SubscriptionView(model: .init(subscription: model.engine.subscription))
                .tabItem {
                    Label("Subscription", systemImage: "tag")
                }
                .tag(Tabs.subscription)
        }
        .frame(width: 420)
        .padding(20)
    }
}

extension SettingsView {

    private enum Tabs: Hashable {
        case general, retentionData, ignore, subscription
    }

    final class Model: ObservableObject {

        let wipe: () -> Void
        let engine: Engine

        init(engine: Engine) {
            self.wipe = engine.history.wipe
            self.engine = engine
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
        SettingsView(model: .init(engine: .previews()))
    }
}
