//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

struct AppExclusionsSettingView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(
                "Avoid storing sensitive data by excluding chosen applications from the pasteboard history."
            )
            List {

                if !viewModel.recommended.isEmpty {
                    Section("Recommended Exclusions") {
                        ForEach(viewModel.recommended, id: \.self) { bundleId in
                            HStack {
                                appIcon(bundleId: bundleId)
                                Text(bundleId)
                                Spacer()
                                Button(
                                    "Add",
                                    action: { [weak viewModel] in
                                        viewModel?.add(bundleId: bundleId)
                                    }
                                )
                            }
                        }
                    }
                }

                Section {
                    if viewModel.apps.isEmpty {
                        Text(
                            "Currently, there are no active exclusions in place. However, you have the option to select some from the recommended list or manually choose excluded apps by clicking the 'Add exclusions' button."
                        )
                    }
                    else {
                        ForEach(viewModel.apps, id: \.self) { bundleId in
                            HStack {
                                appIcon(bundleId: bundleId)
                                Text(bundleId)
                                Spacer()
                                Button(
                                    "Remove",
                                    action: { [weak viewModel] in
                                        viewModel?.remove(bundleId: bundleId)
                                    }
                                )
                            }
                        }
                    }
                } header: {
                    Text("Active exclusions")
                } footer: {
                    Button(
                        "Add exclusion",
                        action: viewModel.openPanel
                    )
                }
            }
        }
    }

    init(appExclusionController: AppExclusionController.Interface) {
        viewModel = .init(appExclusionController: appExclusionController)
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

#Preview {
    AppExclusionsSettingView(
        appExclusionController: AppExclusionController.Previews()
    )
}

