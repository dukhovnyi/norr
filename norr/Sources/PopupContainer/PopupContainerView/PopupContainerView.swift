//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import SwiftUI

struct PopupContainerView: View {

    @ObservedObject var viewModel: ViewModel
    @Environment(\.floatingPanel) var floatingPanel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationView(
                content: {
                    List(viewModel.rows, selection: $viewModel.selection) { row in
                        switch row {
                        case .loadMore:
                            Text("")
                                .frame(height: 100)
                                .onAppear { [weak viewModel] in
                                    withAnimation {
                                        viewModel?.loadMore()
                                    }
                                }
                                .tag(row)

                        case .paste(let item):
                            NavigationLink(
                                destination: ItemDetails(item: item),
                                label: {
                                    Text(item.stringRepresentation.prefix(64))
                                        .allowsHitTesting(false)
                                }
                            )
                            .tag(row)
                            .contentShape(.rect)
                        }
                    }
                    .overlay {
                        if viewModel.rows.isEmpty {
                            VStack {
                                Text("No Data")
                                    .font(.headline)
                                Text("Just copy to get first item here.")
                                    .multilineTextAlignment(.center)
                                    .font(.footnote)
                                    .foregroundStyle(.gray)

                            }
                            .padding()
                        }
                    }

                }
            )
            Divider()
            FooterView(selection: viewModel.selection)
        }
    }

    init(
        app: PasteboardAppManaging.Interface,
        eventMonitor: EventMonitor.Interface
    ) {
        self.viewModel = .init(
            app: app,
            eventMonitor: eventMonitor
        )

        viewModel.hideFloatingPanelPublisher
            .sink(receiveValue: hideApp)
            .store(in: &cancellables)
    }

    func hideApp() {
        NSApplication.shared.keyWindow?.orderOut(nil)
    }

    private var cancellables = Set<AnyCancellable>()
}

struct ItemDetails: View {

    let item: Paste

    var body: some View {
        VStack {
            ItemPreviewView(paste: item)
            ItemInfoView(paste: item)
        }
    }
}

#Preview {
    PopupContainerView(
        app: PasteboardAppManaging.Previews(
            historyController: HistoryManaging.Previews(
                fetch: .success(
                    [
                        .mockColor(),
                        .mockPlainText(),
                        .mockRtf(), 
                        .mockUrl()
                    ]
                )
            )
        ),
        eventMonitor: EventMonitor.Mock()
    )
}
