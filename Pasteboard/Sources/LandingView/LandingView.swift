//
//  LandingView.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 12.03.2023.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {

            HStack {
                Text(Bundle.main.name)
                    .font(.largeTitle)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.bottom, 32)

            VStack(alignment: .leading, spacing: 8) {
                Text("Manage pasteboard history")
                    .font(.title2.bold())
                Text("Keep track of everything you copy to the clipboard, so you can easily access and reuse items.")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Quick access menu & shortcuts")
                    .font(.title2.bold())
                Text("Use **\(Shortcut.stringRepresentation)** or set custom keyboard shortcuts to quick access the application and pasteboard history.")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Preview")
                    .font(.title2.bold())
                Text("Preview items in your clipboard history, so you can easily identify what you're copying and pasting.")
            }

        }
        .padding(32)
        .frame(width: 640, height: 400)
        .fixedSize()
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
