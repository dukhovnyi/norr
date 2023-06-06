//
//  SearchTextField.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 12.05.2023.
//

import SwiftUI

struct SearchTextField: View {

    let placeholder: String
    @Binding var text: String
    @Binding var caseSensetive: Bool
    @Binding var bolted: Bool

    var body: some View {
        HStack {

            TextField(placeholder, text: $text)
                .font(.title)

            HStack(spacing: 16) {
                Button(
                    action: { text.removeAll() },
                    label: { Image(systemName: "xmark.circle.fill") }
                )
                .ifCondition(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) { $0.hidden() }
                Button(
                    action: { caseSensetive.toggle() },
                    label: {
                        Image(systemName: "textformat.size")
                    }
                )
                .ifCondition(caseSensetive, transform: { $0.foregroundColor(.accentColor) })

                Button(
                    action: { bolted.toggle() },
                    label: { Image(systemName: "bolt\(bolted ? ".fill" : "")") }
                )
                .ifCondition(bolted, transform: { $0.foregroundColor(.yellow) })
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal)
        .textFieldStyle(.plain)
    }
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(
            placeholder: "Search ...",
            text: .constant("test"),
            caseSensetive: .constant(true),
            bolted: .constant(true)
        )
    }
}
