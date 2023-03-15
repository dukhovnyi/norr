//
//  EntryPoint.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 21.01.2023.
//

import SwiftUI

@main
struct EntryPoint: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            LandingView()
        }
    }
}
