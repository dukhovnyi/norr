//
//  PasteboardListener.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import AppKit
import Combine

struct PasteboardManaging {

    let event: AnyPublisher<Event, Never>

    let value: AnyPublisher<Paste, Never>
    let start: () -> Void
    let stop: () -> Void
    let apply: (Paste) -> Void
}

extension PasteboardManaging {
    enum Event {
        case start, stop, apply
    }
}

extension PasteboardManaging {

    static func live(
        pasteboard: NSPasteboard,
        interval: TimeInterval,
        now: @escaping () -> Date
    ) -> Self {

        let eventSubj = PassthroughSubject<Event, Never>()
        let valueSubj = PassthroughSubject<Paste, Never>()

        var timer: Timer?
        var changeCount = pasteboard.changeCount

        return .init(
            event: eventSubj.eraseToAnyPublisher(),
            value: valueSubj.eraseToAnyPublisher(),
            start: {
                eventSubj.send(.start)
                timer = Timer.scheduledTimer(
                    withTimeInterval: interval,
                    repeats: true
                ) { timer in

                    guard pasteboard.changeCount != changeCount else { return }
                    changeCount = pasteboard.changeCount

                    let bundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
                    valueSubj.send(
                        .init(
                            id: .init(),
                            changeCount: changeCount,
                            createdAt: now(),
                            pasteboardItems: pasteboard.pasteboardItems ?? [],
                            bundleId: bundleId,
                            isBolted: false
                        )
                    )
                }
            },
            stop: {
                timer?.invalidate()
                timer = nil
                eventSubj.send(.stop)
            },
            apply: { paste in

                pasteboard.clearContents()
                paste.contents.forEach { pasteboard.setData($0.value, forType: $0.type) }
                eventSubj.send(.apply)
            }
        )
    }

}
