//
//  AppExclusionTests.swift
//  norrTests
//
//  Created by Yurii Dukhovnyi on 29/09/2023.
//

import Combine
import XCTest

@testable import norr

final class AppExclusionTests: XCTestCase {

    var appExclusion: AppExclusionController.Impl!
    var storage: QuickStorage.Mock!

    var cancellables = Set<AnyCancellable>()

    let mock = (
        bundleIdA: "com.test.bundle.id.a",
        bundleIdB: "com.test.bundle.id.b"
    )

    override func setUpWithError() throws {

        storage = .init()
        appExclusion = .init(quickStorage: storage)

        try super.setUpWithError()
    }

    func test__addExclusion() {

        var apps = [String]()

        appExclusion.apps
            .sink { apps = $0 }
            .store(in: &cancellables)

        appExclusion.exclude(bundleId: mock.bundleIdA)

        XCTAssertEqual(apps, [mock.bundleIdA])
    }

    func test__doNotCreateDuplications() {

        var apps = [String]()

        appExclusion.apps
            .sink { apps = $0 }
            .store(in: &cancellables)

        appExclusion.exclude(bundleId: mock.bundleIdA)
        appExclusion.exclude(bundleId: mock.bundleIdA)

        XCTAssertEqual(apps, [mock.bundleIdA])
    }

    func test__removeExclusion() {

        var apps = [String]()

        appExclusion.apps
            .sink { apps = $0 }
            .store(in: &cancellables)

        appExclusion.exclude(bundleId: mock.bundleIdA)
        XCTAssertEqual(apps, [mock.bundleIdA])

        appExclusion.removeExclusion(bundleId: mock.bundleIdA)
        XCTAssertEqual(apps, [])
    }

    func test__cantRemoveNotExistExclusion() {

        var apps = [String]()

        appExclusion.apps
            .sink { apps = $0 }
            .store(in: &cancellables)

        appExclusion.exclude(bundleId: mock.bundleIdA)
        XCTAssertEqual(apps, [mock.bundleIdA])

        appExclusion.removeExclusion(bundleId: mock.bundleIdB)
        XCTAssertEqual(apps, [mock.bundleIdA])
    }
}
