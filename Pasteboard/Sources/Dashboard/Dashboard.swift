//
//  Dashboard.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import SwiftUI

struct Dashboard: View {

    @StateObject var viewModel: ViewModel

    var onDidUsePaste: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                List {
                    ForEach(viewModel.items) { item in

                        Row(paste: item)
                            .onTapGesture {
                                onDidUsePaste?()
                                viewModel.use(paste: item)
                            }
                            .padding()

                    }
                }
                .listStyle(.bordered(alternatesRowBackgrounds: true))
                .opacity(viewModel.items.isEmpty ? 0.18 : 1.0)

                if viewModel.items.isEmpty {
                    Text("History is empty")
                        .font(.title3)
                }
            }

            Divider()

            HStack {
                HStack {
                    Text("\(Bundle.main.name)")
                        .font(.title)
                    Text("\(Bundle.main.semver)")
                        .font(.footnote)
                }
                Spacer()
                Button(
                    action: { viewModel.cleanHistory() },
                    label: {
                        Text("Clean history ...")
                    }
                )
                .padding(8)
                .keyboardShortcut("K")

                Divider()

                Button(
                    action: {},
                    label: {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                )
                .padding(8)
                .keyboardShortcut(",")
            }
            .padding(.horizontal)
            .frame(height: 50)
            .buttonStyle(.borderless)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(
            viewModel: .init(keeper: .init(pasteboard: .general, preferencesManaging: .mock(), storage: .mock()))
        )
    }
}


extension Dashboard {

    struct Row: View {

        @State var paste: Paste

        var body: some View {

            HStack {
                Text(paste.stringRepresentation.replacingOccurrences(of: "\r\n", with: "􀅇").prefix(128))
            }
        }
    }
}
