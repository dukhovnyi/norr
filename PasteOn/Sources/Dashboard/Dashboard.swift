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

                        viewModel.preview(for: item)
                            .onTapGesture {
                                viewModel.use(paste: item)
                            }
                            .tag(item)
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
                PreferencesView(viewModel: viewModel.preferencesViewModel())
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
                        Text("Clean history")
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
                worker: .init(historyManaging: .mock(), pasteboardManaging: .mock(), preferences: .mock()),
                onDidPaste: {},
                state: .active,
                analytics: .init(appDidFinishLaunching: { _ in }, logEvent: { _ in })
            )
        )
    }
}

extension View {

    @ViewBuilder func ifLet<Transform: View, V>(
        _ condition: @autoclosure () -> V?,
        @ViewBuilder transform: (Self, V) -> Transform
    ) -> some View {

        if let result = condition() {
            transform(self, result)
        } else {
            self
        }
    }

    @ViewBuilder func ifCondition(
        _ condition: @autoclosure () -> Bool,
        @ViewBuilder transform: (Self) -> some View
    ) -> some View {

        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

extension NSColor {
    convenience init(hex: String) {
        let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
        let ui64 = UInt64(hexString, radix: 16)
        let value = ui64 != nil ? Int(ui64!) : 0
        // #RRGGBB
        var components = (
            R: CGFloat((value >> 16) & 0xff) / 255,
            G: CGFloat((value >> 08) & 0xff) / 255,
            B: CGFloat((value >> 00) & 0xff) / 255,
            a: CGFloat(1)
        )
        if String(hexString).count == 8 {
            // #RRGGBBAA
            components = (
                R: CGFloat((value >> 24) & 0xff) / 255,
                G: CGFloat((value >> 16) & 0xff) / 255,
                B: CGFloat((value >> 08) & 0xff) / 255,
                a: CGFloat((value >> 00) & 0xff) / 255
            )
        }
        self.init(red: components.R, green: components.G, blue: components.B, alpha: components.a)
    }

    func toHex(alpha: Bool = false) -> String? {

        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}