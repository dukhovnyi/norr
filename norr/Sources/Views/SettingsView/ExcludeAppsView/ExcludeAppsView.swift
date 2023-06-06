//
//  ExcludeAppsView.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 02.06.2023.
//

import SwiftUI

struct ExcludeAppsView: View {

    @StateObject var model: Model

    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(model.apps, id: \.self) { bundleId in

                    HStack {
                        appIcon(bundleId: bundleId)
                        Text(bundleId)
                        Spacer()
                        Button(
                            action: { [weak model] in
                                model?.remove(app: bundleId)
                            },
                            label: { Text("Remove") }
                        )
                    }
                }

                Section("Recommended Exclusions") {
                    ForEach(model.recommended, id: \.self) { bundleId in
                        HStack {
                            appIcon(bundleId: bundleId)
                            Text(bundleId)
                            Spacer()
                            Button(
                                action: { [weak model] in
                                    model?.add(app: bundleId)
                                },
                                label: { Text("Add") }
                            )
                        }
                    }
                }
                .opacity(model.recommended.isEmpty ? 0 : 1)
            }
            Text("Avoid storing sensitive data by excluding chosen applications from the pasteboard history.")
                .font(.footnote)
        }
    }

    @ViewBuilder func appIcon(bundleId: String?) -> some View {
        if let bundleId = bundleId,
              let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)?.path {

            Image(nsImage: NSWorkspace.shared.icon(forFile: path))
                .resizable()
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: "camera.metering.unknown")
        }
    }
}

struct IgnoreSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ExcludeAppsView(
            model: .init(excludeApps: .previews(["com.apple.keychainsaccess"]))
        )
    }
}

