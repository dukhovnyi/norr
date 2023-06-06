//
//  AppContainer.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 05.05.2023.
//

import SwiftUI

struct AppContainer: View {

    @StateObject var model: Model

    var body: some View {

        VStack(alignment: .leading) {

            HistoryView(model: .init(engine: model.engine))
                .padding(.top, -32)

            HStack {
                Image("icon")

                Text(model.appVersion)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .opacity(0.3)

//                Text("noor")
//                    .font(.largeTitle)

                Spacer()

                Button(
                    action: { [weak model] in model?.settingsClick() },
                    label: {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                )
                .buttonStyle(.borderless)
            }
            .padding()
        }
    }
}

struct AppContainer_Previews: PreviewProvider {
    static var previews: some View {
        AppContainer(
            model: .init(
                engine: .previews(),
                bundle: .main,
                hideUi: {}
            )
        )
    }
}