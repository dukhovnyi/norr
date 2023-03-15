//
//  Bundle.Extensions.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 29.01.2023.
//

import Foundation

extension Bundle {

    var name: String {
        infoDictionary?["CFBundleName"] as? String ?? ""
    }

    var semver: String {

        [
            infoDictionary?["CFBundleShortVersionString"] as? String,
            infoDictionary?["CFBundleVersion"] as? String
        ]
            .compactMap { $0 }
            .joined(separator: ".")
    }
}
