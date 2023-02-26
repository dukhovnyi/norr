//
//  CoreDataManaging.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 13.02.2023.
//

import CoreData
import Foundation

struct CoreDataManaging {

    let managedObjectContext: () -> NSManagedObjectContext
    let save: () throws -> Void

    func fetch<T: NSFetchRequestResult>(request: NSFetchRequest<T>) throws -> [T] {
        try managedObjectContext().fetch(request)
    }
}

extension CoreDataManaging {

    static func live(
        name: String
    ) -> Self {

        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores { desc, error in
            if let error = error as NSError? {
                debugPrint("🔥 Unresolved error='\(error)', \(error.userInfo)")
            }
        }

        return .init(
            managedObjectContext: { container.viewContext },
            save: {
                try container.viewContext.save()
            }
        )
    }
}
