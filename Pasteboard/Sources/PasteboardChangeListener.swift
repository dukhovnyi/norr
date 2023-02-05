//
//  Pasteboard.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import AppKit
import Combine

/// By timer checks the Pasteboard, verifies the current item
///  and send a new value to `value`. Do nothing if the pasteboard
///  value has not been changed.
///
final class PasteboardChangeListener {

    var value: AnyPublisher<Paste, Never> {
        valuePublisher.eraseToAnyPublisher()
    }

    init(
        pasteboard: NSPasteboard = .general,
        timeInterval: TimeInterval = 1
    ) {
        self.pasteboard = pasteboard
        self.changeCount = pasteboard.changeCount
        self.timeInterval = timeInterval
    }

    /// Schedules timer for checking pasteboard updates.
    ///
    func startObserving() {

        timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(updateValueIfNeeded),
            userInfo: nil,
            repeats: true
        )
    }

    /// Invalidates timer and set it to nil.
    ///
    func stopObserving() {

        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private

    private var changeCount: Int
    private var pasteboard: NSPasteboard
    private var timer: Timer?
    private var timeInterval: TimeInterval
    private let valuePublisher = PassthroughSubject<Paste, Never>()

    @objc
    private func updateValueIfNeeded() {

        guard pasteboard.changeCount != changeCount else { return }
        defer { changeCount = pasteboard.changeCount }

        valuePublisher.send(
            .init(pasteboard: pasteboard)
        )
    }
}
