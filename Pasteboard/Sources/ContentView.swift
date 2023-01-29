//
//  ContentView.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import SwiftUI

struct ContentView: View {

    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack {

            List {
                ForEach(viewModel.items) { item in
                    HStack {
                        Text("\(item.id)")
                        Text(item.string.prefix(64))
                    }
//                    .onTapGesture {
//                        viewModel.use(item)
//                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}

import Combine

extension ContentView {

    final class ViewModel: ObservableObject {

        @Published var items = [Paste]()
//        let worker: Worker
//
//        init(worker: Worker) {
//
//            self.worker = worker
//            items = worker.history.cache
//            historyCancellable = worker.history.value
//                .sink { [weak self] items in
//                    self?.items = items.sorted(by: { $0.id > $1.id })
//                }
//            worker.start()
//        }
//
//        func use(_ paste: Paste) {
//
//            worker.use(paste)
//        }

        // MARK: - Private

        private var historyCancellable: AnyCancellable?
    }
}

private extension Paste {

    var string: String {

        guard let data = contents.first(where: { [.string, .fileURL].contains($0.type) })?.value else {
            return description
        }

        return String(decoding: data, as: UTF8.self)
    }
}
