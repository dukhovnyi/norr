//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import SwiftUI

final class PopupPanel {

    init(builder: @escaping () -> some View) {
        self.rootViewBuilder = { 
            NSHostingView(rootView: builder())
        }
        self.panel = .init(
            contentRect: .init(x: 0, y: 0, width: 700, height: 580)
        )
        self.panel.title = "Toolly"

        setup()
    }

    func orderFront() {
        panel.contentView = rootViewBuilder()
        panel.makeKeyAndOrderFront(nil)
        panel.center()
    }

    // MARK: - Private

    private let rootViewBuilder: () -> NSView
    let panel: FloatingPanel

    private var cancellables = Set<AnyCancellable>()

    private func setup() {

        panel.orderedOut
            .sink { [weak self] in
                self?.panel.contentView = nil
            }
            .store(in: &cancellables)
    }
}
