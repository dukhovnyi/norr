//
//  AppContainer+Model.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 05.05.2023.
//

import Combine
import Foundation

extension AppContainer {

    final class Model: ObservableObject {

        let engine: Engine
        let appName: String
        let appVersion: String
        
        init(
            engine: Engine,
            bundle: Bundle
        ) {
            self.engine = engine
            self.appName = bundle.name
            self.appVersion = bundle.semver
        }
    }

}
