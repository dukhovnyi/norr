//
//  PasteboardApp.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import SwiftUI

@main
struct PasteboardApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init())
        }
        .handlesExternalEvents(matching: ["pasteboard"])
    }
}
