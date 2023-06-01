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
                            Text("Bolt")
                                .font(.footnote)
                        }
                    }
                )
                .ifCondition(model.item.isBolted) { $0.foregroundColor(.yellow) }

                Button(
                    role: .destructive,
                    action: model.remove,
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
        .tag(model.item)
        .buttonStyle(.borderless)
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

struct HistoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRowView(model: .init(item: .mockPlainText(), bolt: {}, remove: {}))
    }
}

extension HistoryRowView {

    struct Model {
        let item: Paste
        let bolt: () -> Void
        let remove: () -> Void
    }

}
