//
//  WorkerTests.swift
//  PasteboardTests
//
//  Created by Yurii Dukhovnyi on 26.02.2023.
//

@testable import noor
import Combine
import XCTest

final class WorkerTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    func test__stateInitial() {

        let sut: Worker = .init(
            historyManaging: .mock(),
            pasteboardManaging: .mock(),
            preferences: .mock()
        )
        var result = [Worker.State]()

        sut.state
            .sink { result.append($0) }
            .store(in: &cancellables)

        XCTAssertEqual(result, [.inactive])
    }

    func test__start() {

        var calls = [PasteboardManaging.Call]()
        var states = [Worker.State]()

        let sut: Worker = .init(
            historyManaging: .mock(),
            pasteboardManaging: .traceableMock { calls.append($0) },
            preferences: .mock()
        )

        sut.state
            .sink {
                states.append($0)
            }
            .store(in: &cancellables)

        sut.start()

        XCTAssertEqual(states, [.inactive, .active])
        XCTAssertEqual(calls, [.start])
    }

    func test__pasteboardGetsValue() {

        let mock = (
            pasteboardValue: PassthroughSubject<Paste, Never>(),
            paste: Paste(id: "mock-id", changeCount: 3, createdAt: .now, contents: [], bundleUrl: nil)
        )
        let pasteboard = PasteboardManaging.mock(value: mock.pasteboardValue)

        var result = [Paste]()

        let sut: Worker = .init(
            historyManaging: .mock(save: { result.append($0) }),
            pasteboardManaging: pasteboard,
            preferences: .mock()
        )
        sut.start()
        mock.pasteboardValue.send(mock.paste)

        XCTAssertEqual(result, [mock.paste])
    }

    func test__stop() {

        var calls = [PasteboardManaging.Call]()
        var states = [Worker.State]()

        let sut: Worker = .init(
            historyManaging: .mock(),
            pasteboardManaging: .traceableMock { calls.append($0) },
            preferences: .mock()
        )

        sut.state
            .sink { states.append($0) }
            .store(in: &cancellables)

        sut.stop()

        XCTAssertEqual(states, [.inactive, .inactive])
        XCTAssertEqual(calls, [.stop])
    }

    func test__usePaste() {

        var result = [PasteboardManaging.Call]()
        let mockPaste = Paste(id: "mock-id", changeCount: 3, createdAt: .now, contents: [], bundleUrl: nil)

        let sut: Worker = .init(
            historyManaging: .mock(),
            pasteboardManaging: .traceableMock { result.append($0) },
            preferences: .mock()
        )

        sut.use(paste: mockPaste)

        XCTAssertEqual(result, [.apply])
    }

    func test__clear() {

        var calls = [HistoryManaging.Call]()

        let sut: Worker = .init(
            historyManaging: .traceableMock { calls.append($0) },
            pasteboardManaging: .mock(),
            preferences: .mock()
        )

        sut.clear()

        XCTAssertEqual(calls, [.clean])
    }
}
