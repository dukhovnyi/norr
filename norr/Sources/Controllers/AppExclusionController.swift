//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

enum AppExclusionController {

    typealias Interface = _AppExclusionControllerInterface

}

protocol _AppExclusionControllerInterface {

    /// Publisher that sends applications bundle identifiers
    ///  that should be ignored for storing into history.
    ///
    var apps: AnyPublisher<[String], Never> { get }

    /// Returns list of bundle identifiers that we recommend
    ///  to exclude.
    ///
    ///  This recomendation based on catching possible sensetive
    ///   data.
    var recommendedForExclusion: [String] { get }

    /// Adds bundle identifier to exclusion list.
    ///  Triggers `apps` publisher event.
    func exclude(bundleId: String)

    /// Removes bundle identifier from exclusion list.
    ///  Triggers `apps` publisher event.
    func removeExclusion(bundleId: String)

}
