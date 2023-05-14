//
//  CoreDataManager.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 17.04.2023.
//

import CoreData
import Foundation

final class CoreDataManager {

    var context: NSManagedObjectContext { container.viewContext }

    init(name: String) {
        self.container = .init(name: name)
        container.loadPersistentStores { desc, error in
            debugPrint("Persistent stores loaded with desc='\(desc)'. Error='\(error.debugDescription)'.")
        }
    }

    /// Returns a new managed object context that executes on a private queue.
    ///
    func backgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }

    /// Drop persistent stores and re-create a new one.
    ///
    func wipe() throws {

        let containerName = container.name

        // Get a reference to a NSPersistentStoreCoordinator
        let storeContainer = container.persistentStoreCoordinator

        // Delete each existing persistent store
        for store in storeContainer.persistentStores {
            try storeContainer.destroyPersistentStore(
                at: store.url!,
                ofType: store.type,
                options: nil
            )
        }

        // Re-create the persistent container
        container = NSPersistentContainer(
            name: containerName // the name of
            // a .xcdatamodeld file
        )

        // Calling loadPersistentStores will re-create the
        // persistent stores
        container.loadPersistentStores { desc, error in
            debugPrint("💡 Persistent stores loaded with desc='\(desc)'. Error='\(error.debugDescription)'.")
        }
    }

    // MARK: - Private

    private var container: NSPersistentContainer
}
