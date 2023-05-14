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
    let engine = Engine(
        history: .live(persistentContainerName: "PasteboardHistory"),
        pasteboard: .live(pasteboard: .general, interval: 0.7, now: { .now })
    )

    var body: some Scene {
        WindowGroup {
//            LandingView()
            AppContainer(model: .init(engine: engine, bundle: .main))
        }
    }
}

