//
//  HistoryRowView.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 18.05.2023.
//

import SwiftUI

struct HistoryRowView: View {

    let model: Model

    var body: some View {
        HStack {
            appIcon(item: model.item)

            Divider()

            RichPreview(model: .init(paste: model.item))

            Divider()

            HStack(spacing: 16) {
                Button(
                    action: model.bolt,
                    label: {
                        VStack {
                            Image(systemName: "bolt\(model.item.isBolted ? ".fill" : "")")
                                .frame(width: 24, height: 24)
                        }
                    }
                )
                .ifCondition(model.item.isBolted) { $0.foregroundColor(.yellow) }

                Menu(
                    content: {
                        if let bundleId = model.item.bundleId {
                            Button("Ignore \(bundleId)", action: model.ignoreBundleId)
                        }
                        Button("Bolt", action: model.bolt)
                        Button("Delete", action: model.remove)
                    },
                    label: {}
                )
                .menuStyle(.borderlessButton)

            }
        }
        .tag(model.item)
        .buttonStyle(.borderless)
    }

    @ViewBuilder func appIcon(item: Paste) -> some View {
        if let bundleId = item.bundleId,
              let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)?.path {

            Image(nsImage: NSWorkspace.shared.icon(forFile: path))
                .resizable()
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: "camera.metering.unknown")
        }
    }
}

struct HistoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRowView(
            model: .init(item: .mockPlainText(), bolt: {}, remove: {}, ignoreBundleId: {})
        )
    }
}

extension HistoryRowView {
    struct Model {
        let item: Paste
        let bolt: () -> Void
        let remove: () -> Void
        let ignoreBundleId: () -> Void
    }
}
