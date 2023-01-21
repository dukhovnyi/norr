//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
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
