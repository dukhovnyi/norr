//
//  PasteboardControllerTests.swift
//  norrTests
//
//  Created by Yurii Dukhovnyi on 26/09/2023.
//

import Combine
import XCTest

@testable import norr

final class PasteboardInstanceTests: XCTestCase {

    var impl: PasteboardInstance.Impl!
    var pasteboard: NSPasteboard!

    override func setUp() {
        super.setUp()

        pasteboard = .init(name: .init(rawValue: "Tests"))
        impl = .init(pasteboard: pasteboard)
    }

    func test__changeCount() {

        let initialChangeCount = pasteboard.changeCount
        
        XCTAssertEqual(impl.changeCount, initialChangeCount)

        impl.apply(paste: .mockColor())
        XCTAssertEqual(impl.changeCount, initialChangeCount + 1)

        impl.apply(paste: .mockImage())
        XCTAssertEqual(impl.changeCount, initialChangeCount + 2)
    }

    func test__apply() {
        let expectedText = String.loremIpsum

        impl.apply(paste: .mockPlainText(text: expectedText))

        XCTAssertEqual(pasteboard.pasteboardItems?.map { $0.string(forType: .string) }, [expectedText])
        XCTAssertEqual(impl.pasteboardItems, pasteboard.pasteboardItems)
    }
}
