//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import CoreData
import Foundation

@available(
    *,
     deprecated,
     message: "Norr doesn't use CoreData database. For cleaning up purposes, this class finding dir and removes sqlite3 related files."
)
enum CoreDataManager {

    static func cleanUp() {
        let container = NSPersistentContainer(name: "PasteboardHistory")

        guard var url = container.persistentStoreDescriptions.first?.url else { return }

        do {
            url.deleteLastPathComponent()
            let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            try urls.forEach {
                try FileManager.default.removeItem(at: $0)
            }
        } catch {
            debugPrint("CoreData sqlite3 database has not been removed. Error='\(error)'.")
        }
    }
}
