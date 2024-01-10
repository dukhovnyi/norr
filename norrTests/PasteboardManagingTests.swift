//
// Copyright © 2024 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import XCTest

@testable import norr

final class PasteboardManagingTests: XCTestCase {

    var impl: PasteboardManaging.Impl!

    var dependency: PasteboardManaging.DependencyMock!
    var pasteboard: PasteboardInstance.Mock!
    var timer: TimerManaging.Mock!
    var cancellables = Set<AnyCancellable>()
    let updateInterval = 0.3

    override func setUp() {

        super.setUp()

        dependency = .init()
        pasteboard = .init()
        timer = .init()

        impl = .init(
            pasteboard: pasteboard,
            dependency: dependency,
            timer: timer,
            updateInterval: updateInterval
        )
    }

    override func tearDown() {
        cancellables.removeAll()
    }

    func test__start() {

        impl.start()
        XCTAssertEqual(timer.m_calls, [.invalidate, .schedule(updateInterval, true)])
    }

    func test__stop() {

        impl.stop()
        XCTAssertEqual(timer.m_calls, [.invalidate])
    }

    func test__setPassboardItem() {

        impl.setPasteboardItem(to: .mockPlainText(text: .loremIpsum))

        XCTAssertEqual(
            pasteboard.pasteboardItems?.map { $0.string(forType: .string) }, 
            [.loremIpsum]
        )
    }

    func test__getCurrentPassboardItem() {

        pasteboard.m_pasteboard.clearContents()
        pasteboard.m_pasteboard.setString(.loremIpsum, forType: .string)

        XCTAssertEqual(
            impl.getCurrentPasteboardItem()?.stringRepresentation,
            .loremIpsum
        )
    }

    func test__pasteUpdate() {

        var items = [Paste]()

        impl.value
            .sink { item in
                items.append(item)
            }
            .store(in: &cancellables)

        impl.start()
        timer.m_emulateTimerExecution()
        pasteboard.changeCount += 1

        timer.m_emulateTimerExecution()
        pasteboard.changeCount += 1
        timer.m_emulateTimerExecution()

        timer.m_emulateTimerExecution() // changeCount has not change, skip.

        XCTAssertEqual(items.map(\.changeCount), [0, 1, 2])
    }
}
