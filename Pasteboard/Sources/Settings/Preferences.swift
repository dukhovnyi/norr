//
//  Preferences.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import Foundation

/// Defines application settings
///
struct Preferences: Equatable, Codable {

    /// Defines maximum possible items in the storage.
    ///
    var storageCapacity: Int

    /// Wipes pasteboard history when application close.
    ///
    var wipeHistoryOnClose: Bool
}

extension Preferences {

    static let def: Self = .init(
        storageCapacity: 300,
        wipeHistoryOnClose: true
    )
}
