//
//  HistoryView.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import SwiftUI

struct HistoryView: View {

    @StateObject var model: Model
    @FocusState private var focusedField: FocusField?

    enum FocusField: Hashable { case search, items }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            SearchTextField(
                placeholder: "Search ...",
                text: $model.search,
                caseSensetive: $model.searchState.caseSensetive,
                bolted: $model.searchState.isBolted
            )
            .focused($focusedField, equals: .search)
            .padding(.vertical)
            .onExitCommand {
                model.search.removeAll()
            }

            List(model.items.lazy.filter(model.searchState()), selection: $model.selected) { item in

                HStack {
                    appIcon(item: item)

                    Divider()

                    RichPreview(model: .init(paste: item))

                    Divider()

                    HStack(spacing: 16) {
                        Button(
                            action: { model.bolt(item: item) },
                            label: {
                                VStack {
                                    Image(systemName: "bolt\(item.isBolted ? ".fill" : "")")
                                        .frame(width: 24, height: 24)
                                    Text("Bolt")
                                        .font(.footnote)
                                }
                            }
                        )
                        .ifCondition(item.isBolted) { $0.foregroundColor(.yellow) }

                        Button(
                            role: .destructive,
                            action: { model.remove(item: item) },
                            label: {
                                VStack {
                                    Image(systemName: "minus.circle")
                                        .frame(width: 24, height: 24)
                                    Text("Remove")
                                        .font(.footnote)
                                }
                            }
                        )
                    }
                }
                .tag(item)
                .buttonStyle(.borderless)
            }
            .focused($focusedField, equals: .items)
        }
    }

    @ViewBuilder func appIcon(item: Paste) -> some View {
        if let path = item.bundleUrl?.path {
            Image(nsImage: NSWorkspace.shared.icon(forFile: path))
                .resizable()
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: "camera.metering.unknown")
        }
    }
}

import Combine

struct HistoryView_Previews: PreviewProvider {

    static var previews: some View {
        HistoryView(
            model: .init(engine: .init(history: .previews(), pasteboard: .mock()))
        )
    }
}
