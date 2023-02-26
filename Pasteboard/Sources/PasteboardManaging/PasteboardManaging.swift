//
//  PasteboardListener.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import AppKit
import Combine

struct PasteboardManaging {

    let value: AnyPublisher<Paste, Never>
    let start: () -> Void
    let stop: () -> Void
    let apply: (Paste) -> Void
}

extension PasteboardManaging {

    static func live(
        pasteboard: NSPasteboard,
        interval: TimeInterval,
        now: @escaping () -> Date
    ) -> Self {

        let valueSubj = PassthroughSubject<Paste, Never>()
        var timer: Timer?
        var changeCount = pasteboard.changeCount

        return .init(
            value: valueSubj.eraseToAnyPublisher(),
            start: {
                timer = Timer.scheduledTimer(
                    withTimeInterval: interval,
                    repeats: true
                ) { timer in

                    guard pasteboard.changeCount != changeCount else { return }
                    changeCount = pasteboard.changeCount
                    valueSubj.send(
                        .init(
                            id: .init(),
                            changeCount: changeCount,
                            createdAt: now(),
                            pasteboardItems: pasteboard.pasteboardItems ?? []
                        )
                    )
                }
            },
            stop: {
                timer?.invalidate()
                timer = nil
            },
            apply: { paste in

                pasteboard.clearContents()
                paste.contents.forEach { pasteboard.setData($0.value, forType: $0.type) }
            }
        )
    }

}
