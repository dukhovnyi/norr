//
//  WorkerTests.swift
//  PasteboardTests
//
//  Created by Yurii Dukhovnyi on 26.02.2023.
//

@testable import Pasteboard
import XCTest

final class WorkerTests: XCTestCase {

    enum Call {
        case start, stop, apply
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_startStop() throws {
        var calls = [Call]()
        let worker = Worker(
            pasteboardManaging: .mock(onStart: { calls.append(.start) }, onStop: { calls.append(.stop) }, onApply: { calls.append(.apply) }),
            preferencesManaging: .mock()
        )

        worker.start()
        worker.use(paste: .init(id: .init(), changeCount: 0, createdAt: .now, contents: []))
        worker.stop()

        XCTAssertEqual(calls, [.start, .apply, .stop])
    }

}
