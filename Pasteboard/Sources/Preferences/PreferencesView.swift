//
//  PreferencesView.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct PreferencesView: View {

    @StateObject
    var viewModel: ViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 16) {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Preferences")
                    .font(.largeTitle)
            }

            VStack {
                HStack {
                    Text("Storage capacity")
                    TextField(
                        "History capacity",
                        value: $viewModel.prefs.storageCapacity,
                        formatter: viewModel.formatter
                    )
                }
                Text("""
Defines the amount of items that will be stored in local storage. When amount of items will exceed capacity oldest item will be removed.
""")
                    .font(.footnote)
            }

            LaunchAtLogin.Toggle("Launch at login")

            KeyboardShortcuts.Recorder(
                "Shortcut for quick access Pasteboard",
                name: .pasteboard
            )
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
                preferences: .mock()
            )
        )
    }
}

