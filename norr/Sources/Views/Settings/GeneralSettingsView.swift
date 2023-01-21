//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

struct GeneralSettingsView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        VStack(alignment: .leading) {

            LaunchAtLoginView()

            SettingsShortcutView()

            Button(
                action: viewModel.cleanHistory,
                label: {
                    HStack {
                        Text("Clean history")
                        if viewModel.cleaningHistory {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                }
            )
            .disabled(viewModel.cleaningHistory)

            Text("Version: \(Bundle.main.semver)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(width: 420, height: 100)
    }

    init(historyController: HistoryManaging.Interface) {
        self.viewModel = .init(historyController: historyController)
    }
}

#Preview {
    GeneralSettingsView(historyController: HistoryManaging.Previews())
}

import Combine

extension GeneralSettingsView {

    final class ViewModel: ObservableObject {

        @Published var cleaningHistory = false

        init(historyController: HistoryManaging.Interface) {

            self.historyController = historyController
        }

        func cleanHistory() {

            cleaningHistory = true

            historyController.clean()
                .sink { [weak self] _ in
                    self?.cleaningHistory = false
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }

        // MARK: - Private

        private let historyController: HistoryManaging.Interface

        private var cancellables = Set<AnyCancellable>()
    }
}
