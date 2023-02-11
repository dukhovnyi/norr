//
//  Dashboard.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import SwiftUI

struct Dashboard: View {

    @StateObject var viewModel: ViewModel

    enum FocusField: Hashable { case pasteboardList }
    @FocusState private var focusedField: FocusField?

    var body: some View {
        VStack(spacing: 0) {

            switch viewModel.content {

            case .pasteboardList:
                ZStack {
                    List(viewModel.items, selection: $viewModel.selected) { item in

                        Row(paste: item)
                            .onTapGesture {
                                viewModel.use(paste: item)
                            }
                            .tag(item)
                            .padding()
                    }
                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                    .listItemTint(.primary)
                    .opacity(viewModel.items.isEmpty ? 0.18 : 1.0)
                    .disabled(viewModel.state == .inactive)
                    .focused($focusedField, equals: .pasteboardList)
                    .blur(radius: viewModel.state == .inactive ? 20 : 0)


                    if viewModel.state == .inactive {

                        VStack {
                            Text("Collecting pasteboard history has been suspended.")
                            Button(
                                action: { [weak viewModel] in viewModel?.start() },
                                label: {
                                    Text("Resume")
                                })
                        }

                    } else {

                        if viewModel.items.isEmpty {
                            Text("Pasteboard history is empty")
                                .font(.title3)
                        }

                    }
                }

            case .preferences:
                PreferencesView(viewModel: .init(history: .inMemory(preferencesManaging: .live()), preferences: .live()))
                    .padding()
                Spacer()
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

                VStack {
                    Button(
                        action: { [weak viewModel] in viewModel?.stateToggle() },
                        label: {
                            VStack {
                                Image(systemName: viewModel.stateButtoneImageName)
                                Text(viewModel.stateButtonTitle)
                            }
                        }
                    )
                }

                Divider()

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
                    action: viewModel.preferencesClick,
                    label: {
                        viewModel.preferencesButtonImage
                    }
                )
                .padding(8)
                .keyboardShortcut(",")
            }
            .padding(.horizontal)
            .frame(height: 50)
            .buttonStyle(.borderless)
        }
        .onAppear {
            focusedField = .pasteboardList
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(
            viewModel: .init(
                keeper: .init(pasteboard: .general, preferencesManaging: .mock(), storage: .mock()),
                onDidPaste: {},
                state: .active
            )
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
