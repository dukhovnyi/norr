//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import AppKit
import Foundation

protocol _PasteboardManagingDependency {
    var frontmostApplication: NSRunningApplication? { get }

    func createId() -> String
    func now() -> Date
}

extension PasteboardManaging {

    final class DependencyImpl: Dependency {

        var frontmostApplication: NSRunningApplication? {
            NSWorkspace.shared.frontmostApplication
        }

        func now() -> Date {
            .now
        }

        func createId() -> String {
            UUID().uuidString
        }
    }

}

extension PasteboardManaging {

    final class DependencyMock: Dependency {

        var m_now: Date = .init()
        var m_uuid: UUID = .init()

        var frontmostApplication: NSRunningApplication? { .init() }

        func now() -> Date {
            m_now
        }

        func createId() -> String {
            m_uuid.uuidString
        }
    }
}
