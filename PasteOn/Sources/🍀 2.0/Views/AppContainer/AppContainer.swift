//
//  AppContainer.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 05.05.2023.
//

import SwiftUI

struct AppContainer: View {

    @StateObject var model: Model

    var body: some View {

        VStack(alignment: .leading) {

            HistoryView(model: .init(engine: model.engine))

            HStack {
                Text(model.appName)
                    .font(.largeTitle)

                Text(model.appVersion)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .opacity(0.3)
            }
            .padding()
        }
    }
}

struct AppContainer_Previews: PreviewProvider {
    static var previews: some View {
        AppContainer(model: .init(engine: .init(history: .previews(), pasteboard: .mock()), bundle: .main))
    }
}
