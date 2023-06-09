//
//  TextPreview.swift
//  norr
//
//  Created by Yurii Dukhovnyi on 08.06.2023.
//

import SwiftUI

struct TextPreview: View {

    @StateObject var model: Model

    var body: some View {
        HStack {
            Text(model.represenation.value)
                .lineLimit(7)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TextPreview_Previews: PreviewProvider {
    static var previews: some View {
        RichPreview(
            model: .init(paste: .mockPlainText())
        )
    }
}

extension TextPreview {

    final class Model: ObservableObject {

        @Published var represenation: Representation

        init(paste: Paste) {
            self.represenation = .init(contents: paste.contents)
        }
    }
}
