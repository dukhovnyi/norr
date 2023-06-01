//
//  EntryPoint.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import SwiftUI

@main
struct EntryPoint: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {

        Settings {            
            SettingsView(model: .init(wipe: delegate.engine.history.wipe))
        }
    }
}

