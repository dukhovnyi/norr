//
//  PreferencesView.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import SwiftUI

struct PreferencesView: View {

    @StateObject
    var viewModel: ViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 32) {

            Text("Settings")
                .font(.largeTitle)

            VStack(alignment: .leading, spacing: 8) {

                Text("History")
                    .font(.title2)

                Picker(
                    "Maximum capacity",
                    selection: $viewModel.prefs.storageCapacity
                ) {
                    Text("3")
                        .tag(3)
                    Text("10")
                        .tag(10)
                    Text("50")
                        .tag(50)
                    Text("100")
                        .tag(100)
                    Text("Unlimited")
                        .tag(Int.max)
                }
                .pickerStyle(SegmentedPickerStyle())

                Picker(
                    "Wipe history on close app",
                    selection: $viewModel.prefs.wipeHistoryOnClose
                ) {
                    Text("yes")
                        .tag(true)
                    Text("no")
                        .tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())

                Button("Clean history") { [weak viewModel] in
                    viewModel?.history.clean()
                }
            }

            Text("\(Bundle.main.name) \(Bundle.main.semver)")
                .font(.footnote)
        }
        .onChange(of: viewModel.prefs) { [weak viewModel] newValue in
            viewModel?.preferences.update(newValue)
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(
            viewModel: .init(
                history: .inMemory(preferencesManaging: .mock()),
                preferences: .mock()
            )
        )
    }
}

