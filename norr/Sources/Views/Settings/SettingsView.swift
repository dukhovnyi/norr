//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        TabView {
            GeneralSettingsView(historyController: viewModel.historyController)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)

            AppExclusionsSettingView(
                appExclusionController: viewModel.appExclusionController
            )
            .tabItem { Label("App Exclusions", systemImage: "eye.trianglebadge.exclamationmark") }
            .tag(Tabs.appExclusions)
        }
        .padding()
    }

    init(
        appExclusionController: AppExclusionController.Interface,
        historyController: HistoryManaging.Interface
    ) {
        self.viewModel = .init(
            appExclusionController: appExclusionController,
            historyController: historyController
        )
    }
}

extension SettingsView {

    private enum Tabs: Hashable {
        case general, appExclusions, purchase
    }

    final class ViewModel: ObservableObject {

        let appExclusionController: AppExclusionController.Interface
        let historyController: HistoryManaging.Interface

        init(
            appExclusionController: AppExclusionController.Interface,
            historyController: HistoryManaging.Interface
        ) {
            self.appExclusionController = appExclusionController
            self.historyController = historyController
        }
    }
}

#Preview {
    SettingsView(
        appExclusionController: AppExclusionController.Previews(),
        historyController: HistoryManaging.Previews()
    )
}
