//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

struct AppMenu: View {
    
    let viewModel: ViewModel

    var body: some View {

        VStack {
            Button(
                action: viewModel.openApp,
                label: {
                    Text("Open app")
                }
            )
            Button(
                action: viewModel.quitApp,
                label: {
                    Text("Quit")
                })
        }
    }
}

#Preview {
    AppMenu(viewModel: AppMenu.ViewModel(openApp: {}, quitApp: {}))
}

extension AppMenu {

    final class ViewModel: ObservableObject {

        let openApp: () -> Void
        let quitApp: () -> Void

        init(
            openApp: @escaping () -> Void,
            quitApp: @escaping () -> Void
        ) {
            self.openApp = openApp
            self.quitApp = quitApp
        }
    }

}
