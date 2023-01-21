//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

extension PopupContainerView {

    struct FooterView: View {

        let selection: PopupContainerView.ViewModel.Row?

        var body: some View {
            HStack {
                Image("icon")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("Norr")
                VStack {
                    Text(Bundle.main.semver)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }

                Spacer()

                switch selection {
                case .paste:
                    Text("Press \(Image(.return)) to copy, \(Image(.deleteForward)) to delete from history")
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 3)
        }
    }

}

#Preview {
    PopupContainerView.FooterView(selection: .paste(.mockColor()))
        .frame(width: 700)
}
